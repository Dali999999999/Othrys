import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/models/tunnel_entity.dart';
import 'package:othrys/core/network/tunnel_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TunnelManager manager;

  setUp(() {
    manager = TunnelManager();
  });

  tearDown(() async {
    await manager.dispose();
  });

  test('TunnelManager reports inactive status for unknown tunnels', () {
    expect(manager.isTunnelActive('unknown-id'), isFalse);
    expect(manager.getTunnelStatus('unknown-id'), equals(TunnelStatus.inactive));
    expect(manager.getTunnelError('unknown-id'), isNull);
    expect(manager.getTunnelMetrics('unknown-id'), isNull);
  });

  test('TunnelManager closeTunnel on non-active tunnel returns success', () async {
    final res = await manager.closeTunnel('non-existent');
    expect(res.isSuccess, isTrue);
    expect(manager.isTunnelActive('non-existent'), isFalse);
    expect(manager.getTunnelStatus('non-existent'), equals(TunnelStatus.inactive));
  });

  test('TunnelManager dispose clears all resources', () async {
    await manager.dispose();
    expect(manager.isTunnelActive('any'), isFalse);
    expect(manager.getTunnelStatus('any'), equals(TunnelStatus.inactive));
  });

  test('TunnelMetrics increments bytes accurately', () {
    final metrics = TunnelMetrics();
    expect(metrics.bytesTransmitted, equals(0));
    expect(metrics.bytesReceived, equals(0));

    metrics.bytesTransmitted += 1024;
    metrics.bytesReceived += 4096;

    expect(metrics.bytesTransmitted, equals(1024));
    expect(metrics.bytesReceived, equals(4096));
  });

  test('TunnelManager rejects non-loopback bindAddress for security', () async {
    const dangerousTunnel = TunnelEntity(
      id: 'tun-evil',
      serverId: 'srv-1',
      name: 'Exposed Tunnel',
      type: TunnelType.local,
      bindAddress: '0.0.0.0',
      localPort: 8080,
      remoteHost: '127.0.0.1',
      remotePort: 80,
    );

    // openTunnel without client connection should fail at bind validation immediately
    final res = await manager.openTunnel(dangerousTunnel, FakeSSHClient());
    expect(res.isFailure, isTrue);
    expect(res.failureOrNull?.message, contains('Security violation'));
  });

  test('restoreTunnelsForServer handles empty active tunnels cleanly', () async {
    final results = await manager.restoreTunnelsForServer('srv-nonexistent', FakeSSHClient());
    expect(results, isEmpty);
  });
}

class FakeSSHClient extends Fake implements SSHClient {}
