import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/service_entry_entity.dart';
import '../../core/network/is_ssh_session_manager.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/systemd_service.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/service_entry_entity.dart';
export '../../core/services/systemd_service.dart' show SystemdService;

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
  final ISSHSessionManager sshManager;
  final ActivityService? activityService;
  final SystemdService systemdService;

  ServicesController({
    required this.sshManager,
    this.activityService,
    SystemdService? systemdService,
  })  : systemdService = systemdService ?? SystemdService(sshManager: sshManager),
        super(const ServicesState());

  /// Queries all loaded systemd service units and their enabled at boot state.
  Future<Result<List<ServiceEntryEntity>>> loadServices(String sessionId, {bool isSilent = false}) async {
    if (!mounted) return const Failure('ServicesController unmounted');
    if (!isSilent) {
      state = state.copyWith(isLoading: state.services.isEmpty, error: null);
    }
    final result = await systemdService.listServices(sessionId);
    if (!mounted) return result;

    if (result.isSuccess) {
      state = state.copyWith(services: result.dataOrNull ?? [], isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.failureOrNull?.message);
    }
    return result;
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

    final result = await systemdService.executeAction(sessionId, unit, action);
    if (result.isSuccess) {
      if (server != null) {
        activityService?.logServiceAction(server, service.unit, action);
      }

      await loadServices(sessionId, isSilent: true);
      if (!mounted) return const Success(null);
      state = state.copyWith(
        pendingUnits: Set<String>.from(state.pendingUnits)..remove(unit),
      );
      return const Success(null);
    } else {
      if (mounted) {
        state = state.copyWith(
          services: previousServices,
          pendingUnits: Set<String>.from(state.pendingUnits)..remove(unit),
          error: result.failureOrNull?.message,
        );
      }
      return result;
    }
  }

  /// Enables a service unit to start at boot.
  Future<Result<void>> enableService(String sessionId, ServiceEntryEntity service, {ServerEntity? server}) =>
      executeServiceAction(sessionId, service, 'enable', server: server);

  /// Disables a service unit from starting at boot.
  Future<Result<void>> disableService(String sessionId, ServiceEntryEntity service, {ServerEntity? server}) =>
      executeServiceAction(sessionId, service, 'disable', server: server);

  /// Fetches the recent journalctl logs for a specific service.
  Future<Result<String>> getJournalLogs(String sessionId, String serviceUnit, {int lines = 150}) =>
      systemdService.getJournalLogs(sessionId, serviceUnit, lines: lines);

  /// Creates and deploys a new systemd unit file on the remote server.
  Future<Result<void>> createService(
    String sessionId,
    ServiceDefinition definition, {
    ServerEntity? server,
  }) async {
    final result = await systemdService.createService(sessionId, definition);
    if (result.isSuccess) {
      final unitName = result.dataOrNull!;
      if (server != null) {
        activityService?.logServiceAction(server, unitName, 'create');
      }

      await loadServices(sessionId);
      return const Success(null);
    } else {
      return Failure(result.failureOrNull?.message ?? 'Failed to create service');
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

/// Riverpod provider for SystemdService.
final systemdServiceProvider = Provider<SystemdService>((ref) {
  return SystemdService(sshManager: ref.watch(sshSessionManagerProvider));
});

/// Riverpod provider for systemd services controller.
final servicesControllerProvider =
    StateNotifierProvider.autoDispose<ServicesController, ServicesState>((ref) {
  return ServicesController(
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
    systemdService: ref.watch(systemdServiceProvider),
  );
});
