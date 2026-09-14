import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/enums/auth_method.dart';
import 'package:vpsmanager/core/enums/connection_state.dart';
import 'package:vpsmanager/core/enums/tunnel_type.dart';

void main() {
  group('AuthMethod', () {
    test('toJson returns correct name', () {
      expect(AuthMethod.password.toJson(), 'password');
      expect(AuthMethod.privateKey.toJson(), 'privateKey');
    });

    test('fromJson deserializes valid, invalid and null values safely', () {
      expect(AuthMethod.fromJson('password'), AuthMethod.password);
      expect(AuthMethod.fromJson('privateKey'), AuthMethod.privateKey);
      expect(AuthMethod.fromJson('PRIVATEKEY'), AuthMethod.privateKey);
      expect(AuthMethod.fromJson('unknown_value'), AuthMethod.password);
      expect(AuthMethod.fromJson(null), AuthMethod.password);
    });
  });

  group('ConnectionState', () {
    test('helper getters work correctly', () {
      expect(ConnectionState.connected.isConnected, isTrue);
      expect(ConnectionState.disconnected.isConnected, isFalse);
      expect(ConnectionState.connecting.isBusy, isTrue);
      expect(ConnectionState.reconnecting.isBusy, isTrue);
      expect(ConnectionState.connected.isBusy, isFalse);
    });
  });

  group('TunnelType', () {
    test('toJson returns correct name', () {
      expect(TunnelType.local.toJson(), 'local');
      expect(TunnelType.remote.toJson(), 'remote');
      expect(TunnelType.dynamic.toJson(), 'dynamic');
    });

    test('fromJson deserializes valid, invalid and null values safely', () {
      expect(TunnelType.fromJson('local'), TunnelType.local);
      expect(TunnelType.fromJson('remote'), TunnelType.remote);
      expect(TunnelType.fromJson('dynamic'), TunnelType.dynamic);
      expect(TunnelType.fromJson('invalid_tunnel'), TunnelType.local);
      expect(TunnelType.fromJson(null), TunnelType.local);
    });
  });
}
