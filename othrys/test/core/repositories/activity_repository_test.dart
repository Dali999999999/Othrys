import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/models/activity_log_entity.dart';
import 'package:vpsmanager/core/repositories/activity_repository.dart';
import 'package:vpsmanager/core/security/encryption_vault.dart';
import 'package:vpsmanager/core/storage/local_storage_service.dart';
import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late EncryptionVault vault;
  late LocalStorageService storage;
  late ActivityRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vps_act_repo_test_');
    vault = EncryptionVault(secureStorage: InMemorySecureStorage());
    await vault.initialize();
    storage = LocalStorageService(
      vault: vault,
      storageDirResolver: () async => tempDir,
    );
    repository = LocalActivityRepository(storage: storage);
  });

  tearDown(() async {
    vault.zeroize();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ActivityRepository appends and loads all activities', () async {
    final log1 = ActivityLogEntity(
      id: 'a1',
      timestamp: DateTime.now(),
      category: ActivityCategory.ssh,
      message: 'Logged in',
      level: ActivityLevel.success,
    );
    final log2 = ActivityLogEntity(
      id: 'a2',
      timestamp: DateTime.now(),
      category: ActivityCategory.docker,
      message: 'Container started',
      level: ActivityLevel.info,
    );

    await repository.append(log1);
    await repository.append(log2);

    final list = (await repository.loadAll()).dataOrNull!;
    expect(list.length, 2);
    expect(list.first.id, 'a2'); // newer on top
  });

  test('ActivityRepository loadPage paginates correctly', () async {
    for (int i = 0; i < 15; i++) {
      await repository.append(ActivityLogEntity(
        id: 'log-$i',
        timestamp: DateTime.now(),
        category: ActivityCategory.system,
        message: 'Event $i',
        level: ActivityLevel.info,
      ));
    }

    final page1 = (await repository.loadPage(offset: 0, limit: 10)).dataOrNull!;
    expect(page1.length, 10);

    final page2 = (await repository.loadPage(offset: 10, limit: 10)).dataOrNull!;
    expect(page2.length, 5);
  });

  test('ActivityRepository clear empties persistent log', () async {
    await repository.append(ActivityLogEntity(
      id: 'log-del',
      timestamp: DateTime.now(),
      category: ActivityCategory.system,
      message: 'To delete',
      level: ActivityLevel.warning,
    ));

    expect((await repository.loadAll()).dataOrNull!.length, 1);
    await repository.clear();
    expect((await repository.loadAll()).dataOrNull!, isEmpty);
  });
}
