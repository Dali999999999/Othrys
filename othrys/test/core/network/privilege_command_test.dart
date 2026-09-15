import 'dart:async';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/enums/connection_state.dart';
import 'package:othrys/core/models/server_entity.dart';
import 'package:othrys/core/network/ssh_session_manager.dart';

class _FakeSSHSocket implements SSHSocket {
  final _controller = StreamController<Uint8List>.broadcast();
  final _sinkController = StreamController<List<int>>.broadcast();

  @override
  Stream<Uint8List> get stream => _controller.stream;

  @override
  StreamSink<List<int>> get sink => _sinkController.sink;

  @override
  Future<void> get done => _controller.done;

  @override
  Future<void> close() async {
    await _controller.close();
    await _sinkController.close();
  }

  @override
  void destroy() {
    _controller.close();
    _sinkController.close();
  }

  @override
  Future<void> flush() async {}
}

class _TestSSHSessionManager extends SSHSessionManager {
  String? lastExecutedCommand;

  @override
  Future<String> executeCommand(String sessionId, String command) async {
    lastExecutedCommand = command;
    return 'SUCCESS';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestSSHSessionManager sshManager;
  final dummyServer = ServerEntity(
    id: 'srv-test',
    name: 'Test VPS',
    host: '192.168.1.10',
    port: 22,
    username: 'ubuntu',
  );

  setUp(() {
    sshManager = _TestSSHSessionManager();
  });

  ActiveSSHSession createSession(String sessionId, UserPrivileges privileges) {
    final client = SSHClient(_FakeSSHSocket(), username: privileges.username);
    return ActiveSSHSession(
      sessionId: sessionId,
      server: dummyServer,
      client: client,
      status: ConnectionState.connected,
      privileges: privileges,
    );
  }

  group('Privilege-aware executeSafeCommand', () {
    test('strips sudo prefix for root user', () async {
      const rootPriv = UserPrivileges(
        uid: 0,
        username: 'root',
        groups: ['root'],
        canSudoWithoutPassword: true,
      );
      final session = createSession('session-root', rootPriv);
      sshManager.registerSessionForTesting(session);

      await sshManager.executeSafeCommand(
        'session-root',
        'sudo',
        ['systemctl', 'restart', 'nginx'],
      );

      expect(sshManager.lastExecutedCommand, "systemctl 'restart' 'nginx'");
    });

    test('retains sudo for sudoer user with passwordless sudo', () async {
      const sudoerPriv = UserPrivileges(
        uid: 1000,
        username: 'ubuntu',
        groups: ['ubuntu', 'sudo'],
        canSudoWithoutPassword: true,
      );
      final session = createSession('session-sudoer', sudoerPriv);
      sshManager.registerSessionForTesting(session);

      await sshManager.executeSafeCommand(
        'session-sudoer',
        'sudo',
        ['systemctl', 'restart', 'nginx'],
      );

      expect(sshManager.lastExecutedCommand, "sudo 'systemctl' 'restart' 'nginx'");
    });

    test('rejects sudo command for standard user without sudo privileges', () async {
      const standardPriv = UserPrivileges(
        uid: 1001,
        username: 'guest',
        groups: ['guest'],
        canSudoWithoutPassword: false,
      );
      final session = createSession('session-standard', standardPriv);
      sshManager.registerSessionForTesting(session);

      expect(
        () => sshManager.executeSafeCommand(
          'session-standard',
          'sudo',
          ['systemctl', 'restart', 'nginx'],
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Permission denied: user "guest" does not have root/sudo privileges'),
        )),
      );

      expect(sshManager.lastExecutedCommand, isNull);
    });

    test('allows non-sudo commands for standard user', () async {
      const standardPriv = UserPrivileges(
        uid: 1001,
        username: 'guest',
        groups: ['guest'],
        canSudoWithoutPassword: false,
      );
      final session = createSession('session-standard-allowed', standardPriv);
      sshManager.registerSessionForTesting(session);

      await sshManager.executeSafeCommand(
        'session-standard-allowed',
        'uptime',
        [],
      );

      expect(sshManager.lastExecutedCommand, 'uptime');
    });
  });
}
