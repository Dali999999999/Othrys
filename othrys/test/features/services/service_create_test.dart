import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/network/ssh_session_manager.dart';
import 'package:othrys/core/utils/result.dart';
import 'package:othrys/features/services/services_controller.dart';

class _MockSSHSessionManager extends Fake implements SSHSessionManager {
  final List<String> executedCommands = [];

  @override
  Future<String> executeSafeCommand(
    String sessionId,
    String baseCommand,
    List<String> arguments, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final full = '$baseCommand ${arguments.join(' ')}';
    executedCommands.add(full);
    return '';
  }

  @override
  Future<String> executeSafeCommandWithStdin(
    String sessionId,
    String baseCommand,
    List<String> arguments,
    Uint8List stdinData,
  ) async {
    final full = '$baseCommand ${arguments.join(' ')}';
    executedCommands.add(full);
    return '';
  }

  @override
  Future<String> executeCommand(
    String sessionId,
    String command, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    executedCommands.add(command);
    return '';
  }
}

void main() {
  group('ServiceDefinition', () {
    test('generateUnitContent creates standard systemd unit configuration', () {
      const def = ServiceDefinition(
        name: 'my-api',
        description: 'Production API backend',
        execStart: '/usr/bin/node /var/www/my-api/index.js',
        workingDirectory: '/var/www/my-api',
        user: 'www-data',
        restartPolicy: 'on-failure',
        environment: {
          'PORT': '3000',
          'NODE_ENV': 'production',
        },
        enableAtBoot: true,
        startNow: true,
      );

      final content = def.generateUnitContent();

      expect(content, contains('[Unit]'));
      expect(content, contains('Description=Production API backend'));
      expect(content, contains('After=network.target'));
      expect(content, contains('[Service]'));
      expect(content, contains('Type=simple'));
      expect(content, contains('User=www-data'));
      expect(content, contains('WorkingDirectory=/var/www/my-api'));
      expect(content, contains('ExecStart=/usr/bin/node /var/www/my-api/index.js'));
      expect(content, contains('Restart=on-failure'));
      expect(content, contains('Environment="PORT=3000"'));
      expect(content, contains('Environment="NODE_ENV=production"'));
      expect(content, contains('[Install]'));
      expect(content, contains('WantedBy=multi-user.target'));
      expect(def.serviceFileName, 'my-api.service');
    });

    test('serviceFileName appends .service only when not already present', () {
      const def1 = ServiceDefinition(name: 'nginx', description: '', execStart: 'nginx');
      expect(def1.serviceFileName, 'nginx.service');

      const def2 = ServiceDefinition(name: 'docker.service', description: '', execStart: 'dockerd');
      expect(def2.serviceFileName, 'docker.service');
    });
  });

  group('ServicesController.createService', () {
    test('writes unit file, reloads daemon, enables, and starts service', () async {
      final mockSsh = _MockSSHSessionManager();
      final controller = ServicesController(sshManager: mockSsh);

      const def = ServiceDefinition(
        name: 'node-app',
        description: 'Node Application',
        execStart: '/usr/bin/node app.js',
        enableAtBoot: true,
        startNow: true,
      );

      final result = await controller.createService('sess-1', def);

      expect(result, isA<Success<void>>());
      expect(mockSsh.executedCommands.length, greaterThanOrEqualTo(3));
      // First command writes to /etc/systemd/system/node-app.service
      expect(mockSsh.executedCommands.any((c) => c.contains('/etc/systemd/system/node-app.service')), isTrue);
      // Reload daemon
      expect(mockSsh.executedCommands.any((c) => c.contains('systemctl daemon-reload')), isTrue);
      // Enable service
      expect(mockSsh.executedCommands.any((c) => c.contains('systemctl enable node-app.service')), isTrue);
      // Start service
      expect(mockSsh.executedCommands.any((c) => c.contains('systemctl start node-app.service')), isTrue);
    });
  });
}
