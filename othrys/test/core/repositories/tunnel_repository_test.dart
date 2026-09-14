import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/models/tunnel_entity.dart';
import 'package:vpsmanager/core/repositories/tunnel_repository.dart';
import 'package:vpsmanager/core/security/encryption_vault.dart';
import 'package:vpsmanager/core/storage/local_storage_service.dart';
import '../../test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late EncryptionVault vault;
  late LocalStorageService storage;
  late TunnelRepository repository;

  final tunnel1 = TunnelEntity(
    id: 'tun-1',
    serverId: 'srv-1',
    name: 'PostgreSQL',
    label: 'DB forward',
    localPort: 5432,
    remoteHost: '127.0.0.1',
    remotePort: 5432,
    type: TunnelType.local,
  );

  final tunnel2 = TunnelEntity(
    id: 'tun-2',
    serverId: 'srv-2',
    name: 'Redis',
    label: 'Cache forward',
    localPort: 6379,
    remoteHost: '127.0.0.1',
    remotePort: 6379,
    type: TunnelType.local,
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vps_tunnel_repo_test_');
    vault = EncryptionVault(secureStorage: InMemorySecureStorage());
    await vault.initialize();
    storage = LocalStorageService(
      vault: vault,
      storageDirResolver: () async => tempDir,
    );
    repository = LocalTunnelRepository(storage: storage);
  });

  tearDown(() async {
    vault.zeroize();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('TunnelRepository saves and loads all tunnels', () async {
    await repository.save(tunnel1);
    await repository.save(tunnel2);

    final listResult = await repository.loadAll();
    expect(listResult.isSuccess, isTrue);
    expect(listResult.dataOrNull?.length, 2);
  });

  test('TunnelRepository loadByServerId filters properly', () async {
    await repository.save(tunnel1);
    await repository.save(tunnel2);

    final server1Tunnels = await repository.loadByServerId('srv-1');
    expect(server1Tunnels.isSuccess, isTrue);
    expect(server1Tunnels.dataOrNull?.length, 1);
    expect(server1Tunnels.dataOrNull?.first.name, 'PostgreSQL');
  });

  test('TunnelRepository delete removes target tunnel', () async {
    await repository.save(tunnel1);
    await repository.save(tunnel2);

    final deleteResult = await repository.delete('tun-1');
    expect(deleteResult.isSuccess, isTrue);

    final remaining = (await repository.loadAll()).dataOrNull!;
    expect(remaining.length, 1);
    expect(remaining.first.id, 'tun-2');
  });

  test('TunnelRepository getById fetches specific tunnel', () async {
    await repository.save(tunnel1);

    final fetchResult = await repository.getById('tun-1');
    expect(fetchResult.isSuccess, isTrue);
    expect(fetchResult.dataOrNull?.name, 'PostgreSQL');
  });
}
