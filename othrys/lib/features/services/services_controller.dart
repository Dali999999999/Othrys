import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/service_entry_entity.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/security/command_sanitizer.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/service_entry_entity.dart';

/// State representation for remote systemd units and execution status.
class ServicesState {
  final List<ServiceEntryEntity> services;
  final bool isLoading;
  final String? error;
  final Set<String> pendingUnits;

  const ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error,
    this.pendingUnits = const {},
  });

  ServicesState copyWith({
    List<ServiceEntryEntity>? services,
    bool? isLoading,
    String? error,
    Set<String>? pendingUnits,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingUnits: pendingUnits ?? this.pendingUnits,
    );
  }
}

/// Controller orchestrating systemd unit discovery, state transitions, and journals.
class ServicesController extends StateNotifier<ServicesState> {
  final SSHSessionManager sshManager;
  final ActivityService? activityService;

  ServicesController({
    required this.sshManager,
    this.activityService,
  }) : super(const ServicesState());

  /// Queries all loaded systemd service units and their enabled at boot state.
  Future<Result<List<ServiceEntryEntity>>> loadServices(String sessionId, {bool isSilent = false}) async {
    if (!mounted) return const Failure('ServicesController unmounted');
    if (!isSilent) {
      state = state.copyWith(isLoading: state.services.isEmpty, error: null);
    }
    try {
      const cmd = 'systemctl list-unit-files --type=service --no-legend --no-pager 2>/dev/null || true; echo "===SPLIT==="; systemctl list-units --type=service --no-legend --no-pager';
      final rawOutput = await sshManager.executeCommand(sessionId, cmd);

      final sections = rawOutput.split('===SPLIT===');
      final enabledMap = <String, bool>{};

      if (sections.isNotEmpty) {
        for (final line in sections[0].trim().split('\n')) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length >= 2) {
            enabledMap[parts[0]] = parts[1].toLowerCase() == 'enabled';
          }
        }
      }

      final unitsSection = sections.length > 1 ? sections[1] : sections[0];
      final List<ServiceEntryEntity> list = [];
      for (final line in unitsSection.trim().split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 5) {
          final unit = parts[0];
          list.add(ServiceEntryEntity(
            unit: unit,
            load: parts[1],
            active: parts[2],
            sub: parts[3],
            description: parts.sublist(4).join(' '),
            isEnabled: enabledMap[unit] ?? false,
          ));
        }
      }

      if (!mounted) return Success(list);
      state = state.copyWith(services: list, isLoading: false);
      return Success(list);
    } catch (e, st) {
      final msg = 'Failed to list systemd services: $e';
      AppLogger.instance.error('ServicesController', msg, e, st);
      if (mounted) {
        state = state.copyWith(isLoading: false, error: msg);
      }
      return Failure(msg, e, st);
    }
  }

  /// Sends a control command ('start', 'stop', 'restart', 'reload', 'enable', 'disable') to target service.
  Future<Result<void>> executeServiceAction(
    String sessionId,
    ServiceEntryEntity service,
    String action, {
    ServerEntity? server,
  }) async {
    const allowed = {'start', 'stop', 'restart', 'reload', 'enable', 'disable'};
    if (!allowed.contains(action)) {
      return Failure('Disallowed systemctl action: $action');
    }

    final unit = service.unit;
    final previousServices = state.services;

    // Optimistic UI update: change state immediately
    final updatedServices = state.services.map((s) {
      if (s.unit == unit) {
        return switch (action) {
          'start' => s.copyWith(active: 'active', sub: 'running'),
          'stop' => s.copyWith(active: 'inactive', sub: 'dead'),
          'enable' => s.copyWith(isEnabled: true),
          'disable' => s.copyWith(isEnabled: false),
          _ => s,
        };
      }
      return s;
    }).toList();

    state = state.copyWith(
      services: updatedServices,
      pendingUnits: {...state.pendingUnits, unit},
      error: null,
    );

    try {
      final sanitizedUnit = CommandSanitizer.sanitizeIdentifier(service.unit);
      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['systemctl', action, sanitizedUnit],
      );

      if (server != null) {
        activityService?.logServiceAction(server, service.unit, action);
      }

      await loadServices(sessionId, isSilent: true);
      if (!mounted) return const Success(null);
      state = state.copyWith(
        pendingUnits: Set<String>.from(state.pendingUnits)..remove(unit),
      );
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to $action ${service.unit}: $e';
      AppLogger.instance.error('ServicesController', msg, e, st);
      if (mounted) {
        state = state.copyWith(
          services: previousServices,
          pendingUnits: Set<String>.from(state.pendingUnits)..remove(unit),
          error: msg,
        );
      }
      return Failure(msg, e, st);
    }
  }

  /// Enables a service unit to start at boot.
  Future<Result<void>> enableService(String sessionId, ServiceEntryEntity service, {ServerEntity? server}) =>
      executeServiceAction(sessionId, service, 'enable', server: server);

  /// Disables a service unit from starting at boot.
  Future<Result<void>> disableService(String sessionId, ServiceEntryEntity service, {ServerEntity? server}) =>
      executeServiceAction(sessionId, service, 'disable', server: server);

  /// Fetches the recent journalctl logs for a specific service.
  Future<Result<String>> getJournalLogs(String sessionId, String serviceUnit, {int lines = 150}) async {
    try {
      final sanitizedUnit = CommandSanitizer.sanitizeIdentifier(serviceUnit);
      final logs = await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['journalctl', '-u', sanitizedUnit, '-n', lines.toString(), '--no-pager'],
      );
      return Success(logs);
    } catch (e, st) {
      final msg = 'Failed to fetch journal logs for $serviceUnit: $e';
      AppLogger.instance.error('ServicesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Creates and deploys a new systemd unit file on the remote server.
  Future<Result<void>> createService(
    String sessionId,
    ServiceDefinition definition, {
    ServerEntity? server,
  }) async {
    try {
      final rawName = definition.name.endsWith('.service')
          ? definition.name.substring(0, definition.name.length - 8)
          : definition.name;
      final sanitizedName = CommandSanitizer.sanitizeIdentifier(rawName);
      final unitName = '$sanitizedName.service';
      final unitContent = definition.generateUnitContent();

      final escaped = unitContent.replaceAll("'", "'\\''");
      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['bash', '-c', "echo '$escaped' > /etc/systemd/system/$unitName && chmod 644 /etc/systemd/system/$unitName"],
      );

      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['systemctl', 'daemon-reload'],
      );

      if (definition.enableAtBoot) {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['systemctl', 'enable', unitName],
        );
      }

      if (definition.startNow) {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['systemctl', 'start', unitName],
        );
      }

      if (server != null) {
        activityService?.logServiceAction(server, unitName, 'create');
      }

      await loadServices(sessionId);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to create service ${definition.name}: $e';
      AppLogger.instance.error('ServicesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }
}

/// Parameters defining a systemd service unit to generate and deploy.
class ServiceDefinition {
  final String name;
  final String description;
  final String execStart;
  final String workingDirectory;
  final String user;
  final String restartPolicy;
  final Map<String, String> environment;
  final bool enableAtBoot;
  final bool startNow;

  const ServiceDefinition({
    required this.name,
    required this.description,
    required this.execStart,
    this.workingDirectory = '',
    this.user = 'root',
    this.restartPolicy = 'always',
    this.environment = const {},
    this.enableAtBoot = true,
    this.startNow = true,
  });

  String get serviceFileName => name.endsWith('.service') ? name : '$name.service';

  String generateUnitContent() {
    final buffer = StringBuffer();
    buffer.writeln('[Unit]');
    buffer.writeln('Description=${description.isEmpty ? name : description}');
    buffer.writeln('After=network.target');
    buffer.writeln();
    buffer.writeln('[Service]');
    buffer.writeln('Type=simple');
    if (user.isNotEmpty) {
      buffer.writeln('User=$user');
    }
    if (workingDirectory.isNotEmpty) {
      buffer.writeln('WorkingDirectory=$workingDirectory');
    }
    buffer.writeln('ExecStart=$execStart');
    buffer.writeln('Restart=$restartPolicy');
    for (final entry in environment.entries) {
      if (entry.key.isNotEmpty) {
        buffer.writeln('Environment="${entry.key}=${entry.value}"');
      }
    }
    buffer.writeln();
    buffer.writeln('[Install]');
    buffer.writeln('WantedBy=multi-user.target');
    return buffer.toString();
  }
}

/// Riverpod provider for systemd services controller.
final servicesControllerProvider =
    StateNotifierProvider.autoDispose<ServicesController, ServicesState>((ref) {
  return ServicesController(
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});
