import 'dart:convert';
import 'dart:typed_data';
import '../models/service_entry_entity.dart';
import '../network/is_ssh_session_manager.dart';
import '../security/command_sanitizer.dart';
import '../utils/logger.dart';
import '../utils/result.dart';
import '../../features/services/services_controller.dart' show ServiceDefinition;

/// Service responsible for remote systemd operations and output parsing over SSH.
class SystemdService {
  final ISSHSessionManager sshManager;

  const SystemdService({required this.sshManager});

  /// Queries all loaded systemd service units and their boot enablement state.
  Future<Result<List<ServiceEntryEntity>>> listServices(String sessionId) async {
    try {
      const cmd =
          'systemctl list-unit-files --type=service --no-legend --no-pager 2>/dev/null || true; '
          'echo "===SPLIT==="; '
          'systemctl list-units --type=service --no-legend --no-pager';
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

      return Success(list);
    } catch (e, st) {
      final msg = 'Failed to list systemd services: $e';
      AppLogger.instance.error('SystemdService', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Sends a control command to the target service unit.
  Future<Result<void>> executeAction(String sessionId, String unit, String action) async {
    const allowed = {'start', 'stop', 'restart', 'reload', 'enable', 'disable'};
    if (!allowed.contains(action)) {
      return Failure('Disallowed systemctl action: $action');
    }

    try {
      final sanitizedUnit = CommandSanitizer.sanitizeIdentifier(unit);
      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['systemctl', action, sanitizedUnit],
      );
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to $action $unit: $e';
      AppLogger.instance.error('SystemdService', msg, e, st);
      return Failure(msg, e, st);
    }
  }

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
      AppLogger.instance.error('SystemdService', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Creates and deploys a new systemd unit file on the remote server using stdin streaming.
  Future<Result<String>> createService(String sessionId, ServiceDefinition definition) async {
    try {
      final rawName = definition.name.endsWith('.service')
          ? definition.name.substring(0, definition.name.length - 8)
          : definition.name;
      final sanitizedName = CommandSanitizer.sanitizeIdentifier(rawName);
      final unitName = '$sanitizedName.service';
      final unitContent = definition.generateUnitContent();

      // Write unit file using sudo tee via stdin without shell interpolation
      await sshManager.executeSafeCommandWithStdin(
        sessionId,
        'sudo',
        ['tee', '/etc/systemd/system/$unitName'],
        Uint8List.fromList(utf8.encode(unitContent)),
      );

      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['chmod', '644', '/etc/systemd/system/$unitName'],
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

      return Success(unitName);
    } catch (e, st) {
      final msg = 'Failed to create service ${definition.name}: $e';
      AppLogger.instance.error('SystemdService', msg, e, st);
      return Failure(msg, e, st);
    }
  }
}
