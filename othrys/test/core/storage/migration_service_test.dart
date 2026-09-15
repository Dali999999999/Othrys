import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:othrys/core/security/encryption_vault.dart';
import 'package:othrys/core/storage/migration_service.dart';

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
  group('MigrationService', () {
    late EncryptionVault vault;
    late MigrationService migrationService;

    setUp(() async {
      final fakeStorage = TestSecureStorage();
      vault = EncryptionVault(secureStorage: fakeStorage);
      await vault.initialize();
      migrationService = MigrationService(vault: vault);
    });

    test('migrates v0 plaintext list to v1 encrypted map with schemaVersion: 1', () async {
      const plainPassword = 'my_plaintext_legacy_password';
      final v0Payload = [
        {
          'id': 'legacy-1',
          'name': 'Legacy Server',
          'host': '1.2.3.4',
          'port': 22,
          'username': 'root',
          'password': plainPassword,
          'privateKey': null,
          'passphrase': null,
        }
      ];

      final migrated = await migrationService.migrateServersJson(v0Payload);

      expect(migrated['schemaVersion'], 1);
      final dataList = migrated['data'] as List<dynamic>;
      expect(dataList.length, 1);

      final migratedServer = dataList.first as Map<String, dynamic>;
      expect(migratedServer['id'], 'legacy-1');
      expect(migratedServer['password'], isNot(equals(plainPassword)));
      expect(vault.isEncrypted(migratedServer['password']), isTrue);

      final decrypted = await vault.decrypt(migratedServer['password']);
      expect(decrypted.getOrThrow(), plainPassword);
    });

    test('preserves already migrated v1 payload', () async {
      final v1Payload = {
        'schemaVersion': 1,
        'data': [
          {'id': 'modern-1', 'name': 'Modern Server'}
        ]
      };

      final result = await migrationService.migrateServersJson(v1Payload);
      expect(result['schemaVersion'], 1);
      expect((result['data'] as List).length, 1);
    });
  });
}
