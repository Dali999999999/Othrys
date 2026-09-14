import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/models/server_entity.dart';
import 'package:vpsmanager/core/repositories/server_repository.dart';
import 'package:vpsmanager/core/security/encryption_vault.dart';
import 'package:vpsmanager/core/storage/local_storage_service.dart';
import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late EncryptionVault vault;
  late LocalStorageService storage;
  late ServerRepository repository;

  final server1 = ServerEntity(
    id: 's1',
    name: 'Prod',
    host: '10.0.0.1',
    port: 22,
    username: 'admin',
    authType: AuthMethod.password,
    password: 'superSecretPassword',
  );

  final server2 = ServerEntity(
    id: 's2',
    name: 'Dev',
    host: '10.0.0.2',
    port: 2222,
    username: 'dev',
    authType: AuthMethod.privateKey,
    privateKey: 'ssh-rsa AAAA...',
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vps_server_repo_test_');
    vault = EncryptionVault(secureStorage: InMemorySecureStorage());
    await vault.initialize();
    storage = LocalStorageService(
      vault: vault,
      storageDirResolver: () async => tempDir,
    );
    repository = LocalServerRepository(storage: storage);
  });

  tearDown(() async {
    vault.zeroize();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ServerRepository saves and loads all servers with transparent decryption', () async {
    final save1 = await repository.save(server1);
    expect(save1.isSuccess, isTrue);

    final save2 = await repository.save(server2);
    expect(save2.isSuccess, isTrue);

    final listResult = await repository.loadAll();
    expect(listResult.isSuccess, isTrue);

    final list = listResult.dataOrNull!;
    expect(list.length, 2);
    expect(list[0].id, 's1');
    expect(list[0].password, 'superSecretPassword');
    expect(list[1].id, 's2');
    expect(list[1].privateKey, 'ssh-rsa AAAA...');
  });

  test('ServerRepository updates existing server in place', () async {
    await repository.save(server1);

    final updated = server1.copyWith(name: 'Prod Renamed');
    final updateResult = await repository.update(updated);
    expect(updateResult.isSuccess, isTrue);

    final fetchResult = await repository.getById('s1');
    expect(fetchResult.isSuccess, isTrue);
    expect(fetchResult.dataOrNull?.name, 'Prod Renamed');
  });

  test('ServerRepository deletes server by ID', () async {
    await repository.save(server1);
    await repository.save(server2);

    final deleteResult = await repository.delete('s1');
    expect(deleteResult.isSuccess, isTrue);

    final list = (await repository.loadAll()).dataOrNull!;
    expect(list.length, 1);
    expect(list.first.id, 's2');
  });

  test('ServerRepository getById returns null for non-existing server', () async {
    final result = await repository.getById('non-existent');
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, isNull);
  });
}
