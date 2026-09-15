import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/is_ssh_session_manager.dart';
import 'package:vpsmanager/core/services/systemd_service.dart';
import 'package:vpsmanager/features/services/services_controller.dart' show ServiceDefinition;

class _MockSSHSessionManager extends Fake implements ISSHSessionManager {
  final List<String> executedCommands = [];
  final List<Uint8List> receivedStdin = [];
  String nextCommandOutput = '';

  @override
  Future<String> executeCommand(String sessionId, String command) async {
    executedCommands.add(command);
    return nextCommandOutput;
  }

  @override
  Future<String> executeSafeCommand(String sessionId, String binary, List<String> args) async {
    final cmd = '$binary ${args.join(' ')}';
    executedCommands.add(cmd);
    return nextCommandOutput;
  }

  @override
  Future<String> executeSafeCommandWithStdin(
    String sessionId,
    String binary,
    List<String> args,
    Uint8List stdinData,
  ) async {
    final cmd = '$binary ${args.join(' ')}';
    executedCommands.add(cmd);
    receivedStdin.add(stdinData);
    return nextCommandOutput;
  }
}

void main() {
  late _MockSSHSessionManager mockSSH;
  late SystemdService systemdService;

  setUp(() {
    mockSSH = _MockSSHSessionManager();
    systemdService = SystemdService(sshManager: mockSSH);
  });

  test('listServices parses systemctl unit files and active units correctly', () async {
    mockSSH.nextCommandOutput = '''
nginx.service enabled
redis.service disabled
===SPLIT===
nginx.service loaded active running High Performance Web Server
redis.service loaded inactive dead Redis In-Memory Store
''';

    final result = await systemdService.listServices('session-1');
    expect(result.isSuccess, isTrue);
    final services = result.dataOrNull!;
    expect(services.length, equals(2));

    expect(services[0].unit, equals('nginx.service'));
    expect(services[0].load, equals('loaded'));
    expect(services[0].active, equals('active'));
    expect(services[0].sub, equals('running'));
    expect(services[0].description, equals('High Performance Web Server'));
    expect(services[0].isEnabled, isTrue);

    expect(services[1].unit, equals('redis.service'));
    expect(services[1].isEnabled, isFalse);
  });

  test('executeAction enforces allowed systemctl commands', () async {
    final badResult = await systemdService.executeAction('session-1', 'nginx.service', 'evil_action');
    expect(badResult.isFailure, isTrue);
    expect(badResult.failureOrNull?.message.contains('Disallowed systemctl action'), isTrue);

    final goodResult = await systemdService.executeAction('session-1', 'nginx.service', 'restart');
    expect(goodResult.isSuccess, isTrue);
    expect(mockSSH.executedCommands, contains('sudo systemctl restart nginx.service'));
  });

  test('createService streams unit file safely over stdin using tee without bash -c', () async {
    const definition = ServiceDefinition(
      name: 'my-app',
      description: 'My Super Service',
      execStart: '/usr/local/bin/app --flag',
      user: 'appuser',
      enableAtBoot: true,
      startNow: true,
    );

    final result = await systemdService.createService('session-1', definition);
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, equals('my-app.service'));

    expect(mockSSH.executedCommands, contains('sudo tee /etc/systemd/system/my-app.service'));
    expect(mockSSH.executedCommands, contains('sudo chmod 644 /etc/systemd/system/my-app.service'));
    expect(mockSSH.executedCommands, contains('sudo systemctl daemon-reload'));
    expect(mockSSH.executedCommands, contains('sudo systemctl enable my-app.service'));
    expect(mockSSH.executedCommands, contains('sudo systemctl start my-app.service'));

    // Verify stdin received the exact unit file content
    expect(mockSSH.receivedStdin, isNotEmpty);
    final stdinStr = utf8.decode(mockSSH.receivedStdin.first);
    expect(stdinStr, contains('[Unit]'));
    expect(stdinStr, contains('Description=My Super Service'));
    expect(stdinStr, contains('ExecStart=/usr/local/bin/app --flag'));
    expect(stdinStr, contains('User=appuser'));
  });

  test('getJournalLogs calls journalctl with safe arguments', () async {
    final result = await systemdService.getJournalLogs('session-1', 'nginx.service', lines: 50);
    expect(result.isSuccess, isTrue);
    expect(mockSSH.executedCommands, contains('sudo journalctl -u nginx.service -n 50 --no-pager'));
  });
}
