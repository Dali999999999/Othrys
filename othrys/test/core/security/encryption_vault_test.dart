import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vpsmanager/core/security/encryption_vault.dart';

class InMemorySecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

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
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }
}

void main() {
  group('EncryptionVault', () {
    late InMemorySecureStorage fakeStorage;
    late EncryptionVault vault;

    setUp(() {
      fakeStorage = InMemorySecureStorage();
      vault = EncryptionVault(secureStorage: fakeStorage);
    });

    test('initializes and generates master key in secure storage', () async {
      expect(vault.isInitialized, isFalse);
      final initResult = await vault.initialize();
      expect(initResult.isSuccess, isTrue);
      expect(vault.isInitialized, isTrue);
    });

    test('round-trip encrypt and decrypt preserves original text', () async {
      const secret = 'super_secret_ssh_password_123!';
      final encrypted = await vault.encrypt(secret);
      expect(encrypted.isSuccess, isTrue);
      final token = encrypted.getOrThrow();
      expect(vault.isEncrypted(token), isTrue);
      expect(token, isNot(contains(secret)));

      final decrypted = await vault.decrypt(token);
      expect(decrypted.isSuccess, isTrue);
      expect(decrypted.getOrThrow(), secret);
    });

    test('encrypting empty string returns empty string', () async {
      final res = await vault.encrypt('');
      expect(res.isSuccess, isTrue);
      expect(res.getOrThrow(), '');
    });

    test('decrypting corrupted token returns Failure', () async {
      // 4 hex parts but invalid data / mac
      const corruptedToken = '00112233445566778899aabbccddeeff:00112233445566778899aabb:deadbeef:cafe00112233445566778899aabbccdd';
      final res = await vault.decrypt(corruptedToken);
      expect(res.isFailure, isTrue);
    });

    test('zeroize cleans internal key state', () async {
      await vault.initialize();
      expect(vault.isInitialized, isTrue);
      vault.zeroize();
      expect(vault.isInitialized, isFalse);
    });
  });
}
