import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/ssh_session_manager.dart';
import '../network/tunnel_manager.dart';
import '../repositories/activity_repository.dart';
import '../repositories/server_repository.dart';
import '../repositories/tunnel_repository.dart';
import '../security/encryption_vault.dart';
import '../security/host_key_store.dart';
import '../services/activity_service.dart';
import '../storage/local_storage_service.dart';

/// Central registry of all core infrastructure and domain repository providers.
final encryptionVaultProvider = Provider<EncryptionVault>((ref) {
  return EncryptionVault.instance;
});

final hostKeyStoreProvider = Provider<HostKeyStore>((ref) {
  return HostKeyStore(vault: ref.watch(encryptionVaultProvider));
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService.instance;
});

final sshSessionManagerProvider = Provider<SSHSessionManager>((ref) {
  return SSHSessionManager.instance;
});

final tunnelManagerProvider = Provider<TunnelManager>((ref) {
  final manager = TunnelManager.instance;
  ref.onDispose(() => manager.dispose());
  return manager;
});

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  return LocalServerRepository(
    storage: ref.watch(localStorageProvider),
  );
});

final tunnelRepositoryProvider = Provider<TunnelRepository>((ref) {
  return LocalTunnelRepository(
    storage: ref.watch(localStorageProvider),
  );
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return LocalActivityRepository(
    storage: ref.watch(localStorageProvider),
  );
});

final activityServiceProvider = Provider<ActivityService>((ref) {
  return ActivityService(
    repository: ref.watch(activityRepositoryProvider),
  );
});
