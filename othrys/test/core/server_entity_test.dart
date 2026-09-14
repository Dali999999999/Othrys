import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/models/server_entity.dart';

void main() {
  group('ServerEntity', () {
    test('serialization roundtrip preserves all fields', () {
      const server = ServerEntity(
        id: 'srv-123',
        name: 'Production Cloud',
        host: '192.168.1.50',
        port: 2222,
        username: 'deployer',
        authType: AuthMethod.password,
        password: 'secure_password_vault',
        group: 'Production',
        bastionId: 'bastion-host-01',
      );

      final json = server.toJson();
      final reconstructed = ServerEntity.fromJson(json);

      expect(reconstructed.id, server.id);
      expect(reconstructed.name, server.name);
      expect(reconstructed.host, server.host);
      expect(reconstructed.port, 2222);
      expect(reconstructed.username, 'deployer');
      expect(reconstructed.authType, AuthMethod.password);
      expect(reconstructed.password, 'secure_password_vault');
      expect(reconstructed.group, 'Production');
      expect(reconstructed.bastionId, 'bastion-host-01');
      expect(reconstructed, server);
    });

    test('equality checks all properties not just id', () {
      const s1 = ServerEntity(id: '1', name: 'Server A', host: '1.1.1.1', username: 'root');
      const s2 = ServerEntity(id: '1', name: 'Server A', host: '1.1.1.1', username: 'root');
      const s3 = ServerEntity(id: '1', name: 'Server B', host: '1.1.1.1', username: 'root');

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });

    test('validate static checks constraints', () {
      expect(ServerEntity.validate(host: '', port: 22, username: 'user'), isNotNull);
      expect(ServerEntity.validate(host: '10.0.0.1', port: 0, username: 'user'), isNotNull);
      expect(ServerEntity.validate(host: '10.0.0.1', port: 70000, username: 'user'), isNotNull);
      expect(ServerEntity.validate(host: '10.0.0.1', port: 22, username: ''), isNotNull);
      expect(ServerEntity.validate(host: '10.0.0.1', port: 22, username: 'user'), isNull);
    });

    test('copyWith supports setting nullable field to null', () {
      const server = ServerEntity(
        id: 'srv-1',
        name: 'Node',
        host: '10.0.0.1',
        username: 'root',
        group: 'Staging',
      );

      final cleared = server.copyWith(group: null);
      expect(cleared.group, isNull);
    });

    test('toString redacts sensitive password and private key', () {
      const server = ServerEntity(
        id: 'srv-1',
        name: 'Node',
        host: '10.0.0.1',
        username: 'root',
        password: 'super_secret_password',
        privateKey: 'private_key_material',
      );

      final str = server.toString();
      expect(str.contains('super_secret_password'), isFalse);
      expect(str.contains('private_key_material'), isFalse);
      expect(str.contains('***'), isTrue);
    });
  });
}
