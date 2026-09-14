import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/models/tunnel_entity.dart';

void main() {
  group('TunnelEntity', () {
    test('JSON round-trip preserves all fields', () {
      const tunnel = TunnelEntity(
        id: 'tun-1',
        serverId: 'srv-1',
        name: 'Database Forward',
        label: 'PostgreSQL forwarding to localhost',
        type: TunnelType.local,
        bindAddress: '127.0.0.1',
        localPort: 5432,
        remoteHost: '127.0.0.1',
        remotePort: 5432,
        isSystemInternal: true,
      );

      final json = tunnel.toJson();
      final reconstructed = TunnelEntity.fromJson(json);

      expect(reconstructed, equals(tunnel));
      expect(reconstructed.id, 'tun-1');
      expect(reconstructed.localPort, 5432);
      expect(reconstructed.remotePort, 5432);
      expect(reconstructed.isSystemInternal, isTrue);
    });

    test('port validation rejects invalid ranges', () {
      expect(TunnelEntity.validate(localPort: 0, remotePort: 80, remoteHost: '127.0.0.1'), isNotNull);
      expect(TunnelEntity.validate(localPort: 8080, remotePort: 70000, remoteHost: '127.0.0.1'), isNotNull);
      expect(TunnelEntity.validate(localPort: 8080, remotePort: 80, remoteHost: ''), isNotNull);
      expect(TunnelEntity.validate(localPort: 8080, remotePort: 80, remoteHost: '127.0.0.1'), isNull);
    });

    test('copyWith updates properties correctly', () {
      const tunnel = TunnelEntity(
        id: 'tun-2',
        serverId: 'srv-1',
        name: 'Web',
        localPort: 8080,
        remoteHost: 'localhost',
        remotePort: 80,
      );

      final updated = tunnel.copyWith(name: 'Secure Web', localPort: 8443, remotePort: 443);
      expect(updated.name, 'Secure Web');
      expect(updated.localPort, 8443);
      expect(updated.remotePort, 443);
      expect(updated.serverId, 'srv-1');
    });
  });
}
