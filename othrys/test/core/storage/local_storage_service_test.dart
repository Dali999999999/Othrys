import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:othrys/core/models/activity_log_entity.dart';
import 'package:othrys/core/models/server_entity.dart';
import 'package:othrys/core/security/encryption_vault.dart';
import 'package:othrys/core/storage/local_storage_service.dart';
import 'package:othrys/core/utils/result.dart';

class TestStorage extends Fake implements FlutterSecureStorage {
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
  group('LocalStorageService (Secure Persistence)', () {
    late Directory tempDir;
    late EncryptionVault vault;
    late LocalStorageService storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('storage_service_test_');
      final secureStorage = TestStorage();
      vault = EncryptionVault(secureStorage: secureStorage);
      await vault.initialize();

      storage = LocalStorageService(
        vault: vault,
        storageDirResolver: () async => tempDir,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('round-trip save and load decrypts sensitive fields in memory', () async {
      const plainPassword = 'production_super_secret_ssh_pass!';
      const plainKey = '-----BEGIN OPENSSH PRIVATE KEY-----\nMIIEowIBAAKCAQEA...';
      const plainPassphrase = 'key_passphrase_secret';

      const server = ServerEntity(
        id: 'srv-prod-1',
        name: 'Production Node 1',
        host: '192.168.1.50',
        port: 22,
        username: 'admin',
        password: plainPassword,
        privateKey: plainKey,
        passphrase: plainPassphrase,
      );

      final saveResult = await storage.saveServers([server]);
      expect(saveResult.isSuccess, isTrue);

      // Verify the raw JSON file on disk DOES NOT contain plaintext password or key
      final rawFile = File('${tempDir.path}/Othrys/servers.json');
      expect(await rawFile.exists(), isTrue);

      final rawContent = await rawFile.readAsString();
      expect(rawContent.contains(plainPassword), isFalse, reason: 'Plaintext password must NEVER appear in raw JSON on disk');
      expect(rawContent.contains(plainKey), isFalse, reason: 'Plaintext private key must NEVER appear in raw JSON on disk');
      expect(rawContent.contains(plainPassphrase), isFalse, reason: 'Plaintext passphrase must NEVER appear in raw JSON on disk');

      // Verify schemaVersion: 1 is present
      final Map<String, dynamic> rawJson = jsonDecode(rawContent);
      expect(rawJson['schemaVersion'], 1);

      // Load through service and verify transparent in-memory decryption
      final loadResult = await storage.loadServers();
      expect(loadResult.isSuccess, isTrue);

      final loadedList = loadResult.getOrThrow();
      expect(loadedList.length, 1);
      final loadedServer = loadedList.first;

      expect(loadedServer.id, server.id);
      expect(loadedServer.password, plainPassword);
      expect(loadedServer.privateKey, plainKey);
      expect(loadedServer.passphrase, plainPassphrase);
    });

    test('loadServers returns empty list if file does not exist', () async {
      final res = await storage.loadServers();
      expect(res.isSuccess, isTrue);
      expect(res.getOrThrow(), isEmpty);
    });

    test('concurrent appendActivityLog calls do not collide or throw', () async {
      final futures = List.generate(
        15,
        (i) => storage.appendActivityLog(
          ActivityLogEntity(
            id: 'log-$i',
            timestamp: DateTime.now(),
            level: ActivityLevel.info,
            category: ActivityCategory.system,
            message: 'Message $i',
          ),
        ),
      );
      await Future.wait(futures);

      final logs = await storage.loadActivityLogs(limit: 50);
      expect(logs.length, 15);
    });

    test('saveServers FAILS explicitly and NEVER writes plaintext if encryption fails', () async {
      final uninitializedVault = EncryptionVault(secureStorage: FakeFailingStorage());
      final insecureStorage = LocalStorageService(
        vault: uninitializedVault,
        storageDirResolver: () async => tempDir,
      );

      final server = ServerEntity(
        id: 'srv-fail',
        name: 'Fail Server',
        host: '192.168.1.100',
        port: 22,
        username: 'root',
        authType: AuthMethod.password,
        password: 'SUPER_SECRET_PLAINTEXT_PASSWORD',
      );

      final saveResult = await insecureStorage.saveServers([server]);
      expect(saveResult.isFailure, isTrue);
      expect((saveResult as Failure).message, contains('Refusing to persist credentials in plaintext'));

      // Verify the servers file does NOT contain the plaintext password!
      final serversFile = File('${tempDir.path}/Othrys/servers.json');
      if (await serversFile.exists()) {
        final content = await serversFile.readAsString();
        expect(content.contains('SUPER_SECRET_PLAINTEXT_PASSWORD'), isFalse);
      }
    });
  });
}

class FakeFailingStorage extends Fake implements FlutterSecureStorage {
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
    throw Exception('Secure storage hardware failure');
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
    throw Exception('Secure storage hardware failure');
  }
}
