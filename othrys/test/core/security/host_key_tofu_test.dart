import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vpsmanager/core/security/encryption_vault.dart';
import 'package:vpsmanager/core/security/host_key_store.dart';

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

void main() {
  group('SSH Host Key Verification & TOFU Security', () {
    late Directory tempDir;
    late EncryptionVault vault;
    late HostKeyStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tofu_test_');
      final secureStorage = _FakeSecureStorage();
      vault = EncryptionVault(secureStorage: secureStorage);
      await vault.initialize();
      store = HostKeyStore(
        getStorageDir: () async => tempDir,
        vault: vault,
      );
      await store.load();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('first connection to unknown host returns HostKeyStatus.unknown', () async {
      final status = await store.verifyHostKey('example.com', 22, 'aa:bb:cc:dd');
      expect(status, equals(HostKeyStatus.unknown));
    });

    test('trusted host key matches and returns HostKeyStatus.trusted', () async {
      await store.trustHost('example.com', 22, 'aa:bb:cc:dd');
      final status = await store.verifyHostKey('example.com', 22, 'aa:bb:cc:dd');
      expect(status, equals(HostKeyStatus.trusted));
    });

    test('CRITICAL SECURITY: changed host key returns HostKeyStatus.changed to block MITM', () async {
      await store.trustHost('example.com', 22, 'aa:bb:cc:dd');
      final status = await store.verifyHostKey('example.com', 22, 'ff:ee:dd:cc');
      expect(status, equals(HostKeyStatus.changed));
    });

    test('different port on same host is tracked independently', () async {
      await store.trustHost('example.com', 22, 'aa:bb:cc:dd');
      final statusDifferentPort = await store.verifyHostKey('example.com', 2222, 'aa:bb:cc:dd');
      expect(statusDifferentPort, equals(HostKeyStatus.unknown));
    });

    test('untrustHost removes the host key from trusted store', () async {
      await store.trustHost('example.com', 22, 'aa:bb:cc:dd');
      expect(await store.verifyHostKey('example.com', 22, 'aa:bb:cc:dd'), equals(HostKeyStatus.trusted));

      await store.removeHost('example.com', 22);
      expect(await store.verifyHostKey('example.com', 22, 'aa:bb:cc:dd'), equals(HostKeyStatus.unknown));
    });
  });
}
