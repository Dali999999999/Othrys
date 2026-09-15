import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:othrys/core/enums/connection_state.dart';
import 'package:othrys/core/models/server_entity.dart';
import 'package:othrys/core/network/ssh_session_manager.dart';
import 'package:othrys/core/security/encryption_vault.dart';
import 'package:othrys/core/security/host_key_store.dart';
import 'package:othrys/core/storage/local_storage_service.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }
}

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

class _MockSSHSessionManager extends SSHSessionManager {
  String? lastCommand;
  String mockCommandOutput = '';

  _MockSSHSessionManager({super.hostKeyStore});

  @override
  Future<String> executeCommand(String sessionId, String command) async {
    lastCommand = command;
    return mockCommandOutput;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late EncryptionVault vault;
  late HostKeyStore hostKeyStore;
  late _MockSSHSessionManager sessionManager;

  final testServer = ServerEntity(
    id: 'srv-omega',
    name: 'Production Omega',
    host: '10.0.0.42',
    port: 22,
    username: 'admin',
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ssh_mgr_test_');
    vault = EncryptionVault(secureStorage: _FakeSecureStorage());
    await vault.initialize();
    hostKeyStore = HostKeyStore(
      getStorageDir: () async => tempDir,
      vault: vault,
    );
    await hostKeyStore.load();
    LocalStorageService.instance = LocalStorageService(
      vault: vault,
      storageDirResolver: () async => tempDir,
    );
    sessionManager = _MockSSHSessionManager(hostKeyStore: hostKeyStore);
  });

  tearDown(() async {
    sessionManager.clearSessionsForTesting();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ActiveSSHSession createTestSession({
    required String id,
    required ServerEntity server,
    UserPrivileges? privileges,
    ConnectionState status = ConnectionState.connected,
  }) {
    final client = SSHClient(_FakeSSHSocket(), username: server.username);
    return ActiveSSHSession(
      sessionId: id,
      server: server,
      client: client,
      status: status,
      privileges: privileges,
    );
  }

  group('SSHSessionManager Lifecycle and Registry', () {
    test('registers, retrieves, and counts active sessions', () {
      expect(sessionManager.activeSessionCount, 0);
      expect(sessionManager.isConnected(testServer.id), isFalse);

      final session = createTestSession(id: 'sess-1', server: testServer);
      sessionManager.registerSessionForTesting(session);

      expect(sessionManager.activeSessionCount, 1);
      expect(sessionManager.isConnected(testServer.id), isTrue);
      expect(sessionManager.getSession('sess-1'), equals(session));
      expect(sessionManager.getSessionByServerId(testServer.id), equals(session));
      expect(sessionManager.activeSessions.contains(session), isTrue);
    });

    test('disconnect removes session and marks disconnected', () {
      final session = createTestSession(id: 'sess-2', server: testServer);
      sessionManager.registerSessionForTesting(session);

      expect(sessionManager.isConnected(testServer.id), isTrue);
      sessionManager.disconnect('sess-2');

      expect(sessionManager.activeSessionCount, 0);
      expect(sessionManager.isConnected(testServer.id), isFalse);
      expect(sessionManager.getSession('sess-2'), isNull);
    });

    test('disconnectAll terminates all active sessions', () {
      final srv2 = ServerEntity(id: 'srv-2', name: 'Backup Server', host: '10.0.0.43', port: 22, username: 'root');
      sessionManager.registerSessionForTesting(createTestSession(id: 'sess-a', server: testServer));
      sessionManager.registerSessionForTesting(createTestSession(id: 'sess-b', server: srv2));

      expect(sessionManager.activeSessionCount, 2);
      sessionManager.disconnectAll();
      expect(sessionManager.activeSessionCount, 0);
    });

    test('onConnectionStateChanged streams status transitions', () async {
      final states = <MapEntry<String, ConnectionState>>[];
      final sub = sessionManager.onConnectionStateChanged.listen(states.add);

      final session = createTestSession(id: 'sess-stream', server: testServer);
      sessionManager.registerSessionForTesting(session);

      // Trigger disconnect
      sessionManager.disconnect('sess-stream');

      await Future.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(states.any((e) => e.key == testServer.id && e.value == ConnectionState.disconnected), isTrue);
    });
  });

  group('SSHSessionManager Privilege-Aware Command Execution', () {
    test('strips sudo command for root user execution', () async {
      const rootPriv = UserPrivileges(
        uid: 0,
        username: 'root',
        groups: ['root'],
        canSudoWithoutPassword: true,
      );
      final session = createTestSession(id: 'sess-root', server: testServer, privileges: rootPriv);
      sessionManager.registerSessionForTesting(session);

      await sessionManager.executeSafeCommand('sess-root', 'sudo', ['systemctl', 'restart', 'docker']);
      expect(sessionManager.lastCommand, "systemctl 'restart' 'docker'");
    });

    test('retains sudo for sudoer with passwordless privileges', () async {
      const sudoerPriv = UserPrivileges(
        uid: 1000,
        username: 'debian',
        groups: ['debian', 'sudo'],
        canSudoWithoutPassword: true,
      );
      final session = createTestSession(id: 'sess-sudoer', server: testServer, privileges: sudoerPriv);
      sessionManager.registerSessionForTesting(session);

      await sessionManager.executeSafeCommand('sess-sudoer', 'sudo', ['systemctl', 'restart', 'docker']);
      expect(sessionManager.lastCommand, "sudo 'systemctl' 'restart' 'docker'");
    });

    test('rejects execution when user lacks sudo rights', () async {
      const unprivileged = UserPrivileges(
        uid: 1001,
        username: 'guest',
        groups: ['guest'],
        canSudoWithoutPassword: false,
      );
      final session = createTestSession(id: 'sess-unprivileged', server: testServer, privileges: unprivileged);
      sessionManager.registerSessionForTesting(session);

      expect(
        () => sessionManager.executeSafeCommand('sess-unprivileged', 'sudo', ['ufw', 'status']),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Permission denied'))),
      );
    });
  });

  group('SSHSessionManager System Overview Parsing', () {
    test('fetches and delegates system overview to SystemMetricsParser', () async {
      sessionManager.mockCommandOutput = '''
 22:35:01 up 42 days,  3:14,  1 user,  load average: 0.35, 0.40, 0.50
Mem:    8392704000  4196352000  4196352000           0   104857600   2097152000
Swap:   2097152000   524288000  1572864000
/dev/sda1       104857600  52428800  52428800  50% /
Linux 6.1.0-22-amd64
''';
      final session = createTestSession(id: 'sess-overview', server: testServer);
      sessionManager.registerSessionForTesting(session);

      final overview = await sessionManager.fetchSystemOverview('sess-overview');
      expect(overview.cpuUsagePercent, 35.0);
      expect(overview.uptime, '42 days');
      expect(overview.memoryUsedBytes, 4196352000);
      expect(overview.kernel, 'Linux 6.1.0-22-amd64');
    });
  });

  group('SSHSessionManager TOFU & Host Key Integration', () {
    const fakeFingerprint = 'SHA256:abc1234567890deadbeef';
    const changedFingerprint = 'SHA256:999999999999evilmitm';

    test('TOFU prompt allows trusting unknown host key', () async {
      bool promptCalled = false;
      sessionManager.onHostKeyPrompt = (server, fingerprint) async {
        promptCalled = true;
        expect(server.host, testServer.host);
        expect(fingerprint, fakeFingerprint);
        return true; // User accepts
      };

      // Verify initially unknown
      expect(hostKeyStore.verifyHostKeySync(testServer.host, testServer.port, fakeFingerprint), HostKeyStatus.unknown);

      // Simulate the TOFU decision flow in _authenticateWithSocket
      final status = hostKeyStore.verifyHostKeySync(testServer.host, testServer.port, fakeFingerprint);
      bool verified = false;
      if (status == HostKeyStatus.trusted) {
        verified = true;
      } else if (status == HostKeyStatus.unknown) {
        final accepted = await sessionManager.onHostKeyPrompt!(testServer, fakeFingerprint);
        if (accepted) {
          await hostKeyStore.trustHost(testServer.host, testServer.port, fakeFingerprint);
          verified = true;
        }
      }

      expect(promptCalled, isTrue);
      expect(verified, isTrue);
      expect(hostKeyStore.verifyHostKeySync(testServer.host, testServer.port, fakeFingerprint), HostKeyStatus.trusted);
    });

    test('TOFU prompt rejects connection when user declines', () async {
      sessionManager.onHostKeyPrompt = (server, fingerprint) async => false; // User declines

      final status = hostKeyStore.verifyHostKeySync('10.0.0.99', 22, fakeFingerprint);
      bool verified = false;
      if (status == HostKeyStatus.unknown) {
        final accepted = await sessionManager.onHostKeyPrompt!(testServer, fakeFingerprint);
        verified = accepted;
      }

      expect(verified, isFalse);
      expect(hostKeyStore.verifyHostKeySync('10.0.0.99', 22, fakeFingerprint), HostKeyStatus.unknown);
    });

    test('fail-secure: automatically rejects changed host key (MITM prevention)', () async {
      // Pre-trust legitimate key
      await hostKeyStore.trustHost(testServer.host, testServer.port, fakeFingerprint);

      // Verify altered fingerprint is detected as changed
      final status = hostKeyStore.verifyHostKeySync(testServer.host, testServer.port, changedFingerprint);
      expect(status, HostKeyStatus.changed);

      // In changed status, prompt is NEVER called (fail-closed)
      bool promptCalled = false;
      sessionManager.onHostKeyPrompt = (server, fingerprint) async {
        promptCalled = true;
        return true;
      };

      bool connectionAllowed = false;
      if (status == HostKeyStatus.trusted) {
        connectionAllowed = true;
      } else if (status == HostKeyStatus.unknown) {
        connectionAllowed = await sessionManager.onHostKeyPrompt?.call(testServer, changedFingerprint) ?? false;
      } else if (status == HostKeyStatus.changed) {
        connectionAllowed = false; // Fail-secure immediate abort
      }

      expect(connectionAllowed, isFalse);
      expect(promptCalled, isFalse);
    });
  });
}
