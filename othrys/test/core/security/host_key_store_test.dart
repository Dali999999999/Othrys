import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vpsmanager/core/security/encryption_vault.dart';
import 'package:vpsmanager/core/security/host_key_store.dart';

class TestSecureStorage extends Fake implements FlutterSecureStorage {
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
  group('HostKeyStore (TOFU)', () {
    late Directory tempDir;
    late EncryptionVault vault;
    late HostKeyStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('host_key_store_test_');
      final fakeStorage = TestSecureStorage();
      vault = EncryptionVault(secureStorage: fakeStorage);
      await vault.initialize();
      store = HostKeyStore(
        getStorageDir: () async => tempDir,
        vault: vault,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('first connection returns HostKeyStatus.unknown', () async {
      final status = await store.verifyHostKey('192.168.1.100', 22, 'SHA256:abc123fingerprint');
      expect(status, HostKeyStatus.unknown);
    });

    test('trustHost then verify with same fingerprint returns HostKeyStatus.trusted', () async {
      const host = '192.168.1.100';
      const port = 22;
      const fp = 'SHA256:abc123fingerprint';

      await store.trustHost(host, port, fp);

      final status = await store.verifyHostKey(host, port, fp);
      expect(status, HostKeyStatus.trusted);
    });

    test('reconnection with changed fingerprint returns HostKeyStatus.changed (MITM prevention)', () async {
      const host = '192.168.1.100';
      const port = 22;
      const originalFp = 'SHA256:original_fingerprint';
      const rogueFp = 'SHA256:rogue_mitm_fingerprint';

      await store.trustHost(host, port, originalFp);

      final status = await store.verifyHostKey(host, port, rogueFp);
      expect(status, HostKeyStatus.changed);
    });

    test('removeHost removes host and returns unknown on next verify', () async {
      const host = '10.0.0.1';
      const port = 2222;
      const fp = 'SHA256:some_valid_fingerprint';

      await store.trustHost(host, port, fp);
      expect(await store.verifyHostKey(host, port, fp), HostKeyStatus.trusted);

      await store.removeHost(host, port);
      expect(await store.verifyHostKey(host, port, fp), HostKeyStatus.unknown);
    });
  });
}
