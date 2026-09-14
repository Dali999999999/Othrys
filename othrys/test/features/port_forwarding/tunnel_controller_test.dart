import 'dart:async';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/enums/connection_state.dart';
import 'package:vpsmanager/core/models/server_entity.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/core/repositories/tunnel_repository.dart';
import 'package:vpsmanager/core/utils/result.dart';
import 'package:vpsmanager/features/port_forwarding/tunnel_controller.dart';

class FakeTunnelRepository implements TunnelRepository {
  final List<TunnelEntity> tunnels = [];

  @override
  Future<Result<List<TunnelEntity>>> loadAll() async => Success(List.from(tunnels));

  @override
  Future<Result<List<TunnelEntity>>> loadByServerId(String serverId) async =>
      Success(tunnels.where((t) => t.serverId == serverId).toList());

  @override
  Future<Result<void>> save(TunnelEntity tunnel) async {
    final idx = tunnels.indexWhere((t) => t.id == tunnel.id);
    if (idx >= 0) {
      tunnels[idx] = tunnel;
    } else {
      tunnels.add(tunnel);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    tunnels.removeWhere((t) => t.id == id);
    return const Success(null);
  }

  @override
  Future<Result<TunnelEntity?>> getById(String id) async {
    return Success(tunnels.where((t) => t.id == id).firstOrNull);
  }
}

class FakeSSHSocket implements SSHSocket {
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

class FakeTunnelManager extends TunnelManager {
  final Set<String> fakeActive = {};

  @override
  bool isTunnelActive(String tunnelId) => fakeActive.contains(tunnelId);

  @override
  Future<Result<int>> openTunnel(TunnelEntity tunnel, dynamic client) async {
    fakeActive.add(tunnel.id);
    return Success(tunnel.localPort);
  }

  @override
  Future<Result<void>> closeTunnel(String tunnelId) async {
    fakeActive.remove(tunnelId);
    return const Success(null);
  }
}

class FakeSSHSessionManager extends SSHSessionManager {
  final Map<String, ActiveSSHSession> sessions = {};

  @override
  ActiveSSHSession? getSession(String sessionId) => sessions[sessionId];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TunnelState initial state is empty', () {
    const state = TunnelState();
    expect(state.tunnels, isEmpty);
    expect(state.activeStatuses, isEmpty);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('TunnelController creates, loads, and deletes tunnels', () async {
    final repo = FakeTunnelRepository();
    final tunnelMgr = FakeTunnelManager();
    final sshMgr = FakeSSHSessionManager();
    final controller = TunnelController(
      repository: repo,
      sshManager: sshMgr,
      tunnelManager: tunnelMgr,
    );

    final tunnel = TunnelEntity(
      id: 'tun-1',
      serverId: 'srv-1',
      name: 'Database Tunnel',
      label: 'Database tunnel',
      localPort: 5432,
      remoteHost: '127.0.0.1',
      remotePort: 5432,
      type: TunnelType.local,
    );

    final saveResult = await controller.createTunnel(tunnel);
    expect(saveResult.isSuccess, isTrue);
    expect(controller.state.tunnels.length, 1);
    expect(controller.state.tunnels.first.label, 'Database tunnel');

    // Toggle without active session fails
    final toggleFail = await controller.toggleTunnel('no-session', tunnel);
    expect(toggleFail.isFailure, isTrue);

    // Register a dummy active session
    final dummyServer = const ServerEntity(
      id: 'srv-1',
      name: 'Test Server',
      host: '1.2.3.4',
      port: 22,
      username: 'root',
    );
    final dummyClient = SSHClient(FakeSSHSocket(), username: 'root');
    final dummySession = ActiveSSHSession(
      sessionId: 'session-1',
      server: dummyServer,
      client: dummyClient,
      status: ConnectionState.connected,
    );
    sshMgr.sessions['session-1'] = dummySession;

    // Toggle ON
    final toggleOn = await controller.toggleTunnel('session-1', tunnel);
    expect(toggleOn.isSuccess, isTrue);
    expect(toggleOn.getOrElse(() => false), isTrue);
    expect(controller.state.activeStatuses[tunnel.id], isTrue);

    // Toggle OFF
    final toggleOff = await controller.toggleTunnel('session-1', tunnel);
    expect(toggleOff.isSuccess, isTrue);
    expect(toggleOff.getOrElse(() => true), isFalse);
    expect(controller.state.activeStatuses[tunnel.id], isFalse);

    // Delete tunnel
    final delResult = await controller.deleteTunnel(tunnel.id, serverId: 'srv-1');
    expect(delResult.isSuccess, isTrue);
    expect(controller.state.tunnels, isEmpty);
  });
}

