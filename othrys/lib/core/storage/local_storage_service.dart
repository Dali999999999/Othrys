import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/server_entity.dart';
import '../models/tunnel_entity.dart';
import '../models/activity_log_entity.dart';
import '../security/encryption_vault.dart';
import '../utils/logger.dart';
import '../utils/result.dart';

/// Local persistence service managing encrypted servers, activity logs, and settings.
class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService();
  final EncryptionVault _vault;
  final Future<Directory> Function() _storageDirResolver;

  Directory? _cachedBaseDir;

  LocalStorageService({
    EncryptionVault? vault,
    Future<Directory> Function()? storageDirResolver,
  })  : _vault = vault ?? EncryptionVault.instance,
        _storageDirResolver = storageDirResolver ?? getApplicationSupportDirectory;

  Future<Directory> get _storageDirectory async {
    if (_cachedBaseDir != null) return _cachedBaseDir!;
    final baseDir = await _storageDirResolver();
    final othrysDir = Directory(p.join(baseDir.path, 'Othrys'));
    if (!await othrysDir.exists()) {
      await othrysDir.create(recursive: true);
    }
    _cachedBaseDir = othrysDir;
    return _cachedBaseDir!;
  }

  Future<File> get _serversFile async => File(p.join((await _storageDirectory).path, 'servers.json'));
  Future<File> get _activityFile async => File(p.join((await _storageDirectory).path, 'activity.json'));
  Future<File> get _knownHostsFile async => File(p.join((await _storageDirectory).path, 'known_hosts.json'));

  Future<void> _writeQueue = Future.value();

  Future<T> _enqueueWrite<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _writeQueue = _writeQueue.whenComplete(() async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<void> _atomicWriteLocked(File targetFile, String content) async {
    final tmpFile = File('${targetFile.path}.${DateTime.now().microsecondsSinceEpoch}.tmp');
    try {
      await tmpFile.writeAsString(content, flush: true);
      if (await targetFile.exists()) {
        final bakFile = File('${targetFile.path}.bak');
        try {
          await targetFile.copy(bakFile.path);
        } catch (e) {
          AppLogger.instance.warn('LocalStorage', 'Could not create backup file: $e');
        }
        try {
          await targetFile.delete();
        } catch (e) {
          AppLogger.instance.warn('LocalStorage', 'Could not delete old target file before rename: $e');
        }
      }
      try {
        await tmpFile.rename(targetFile.path);
      } catch (e) {
        // Fallback on Windows if rename fails due to transient locks or filesystem semantics
        await tmpFile.copy(targetFile.path);
        await tmpFile.delete();
      }
    } catch (e) {
      if (await tmpFile.exists()) {
        try {
          await tmpFile.delete();
        } catch (delErr) {
          AppLogger.instance.warn('LocalStorage', 'Failed to remove temporary file: $delErr');
        }
      }
      rethrow;
    }
  }

  Future<void> _atomicWrite(File targetFile, String content) =>
      _enqueueWrite(() => _atomicWriteLocked(targetFile, content));

  /// Loads all servers with credentials decrypted in memory.
  Future<Result<List<ServerEntity>>> loadServers() async {
    final file = await _serversFile;
    if (!await file.exists()) return const Success([]);

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return const Success([]);

      final dynamic decoded = jsonDecode(content);
      final List<dynamic> jsonList;
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        jsonList = decoded['data'] as List<dynamic>;
      } else if (decoded is List<dynamic>) {
        jsonList = decoded;
      } else {
        return const Failure('Unexpected servers JSON format');
      }

      final servers = <ServerEntity>[];
      for (final raw in jsonList) {
        final server = ServerEntity.fromJson(raw as Map<String, dynamic>);
        String? decryptedPassword;
        if (server.password != null && server.password!.isNotEmpty) {
          final res = await _vault.decrypt(server.password!);
          decryptedPassword = res.getOrElse(() => server.password!);
        }
        String? decryptedKey;
        if (server.privateKey != null && server.privateKey!.isNotEmpty) {
          final res = await _vault.decrypt(server.privateKey!);
          decryptedKey = res.getOrElse(() => server.privateKey!);
        }
        String? decryptedPassphrase;
        if (server.passphrase != null && server.passphrase!.isNotEmpty) {
          final res = await _vault.decrypt(server.passphrase!);
          decryptedPassphrase = res.getOrElse(() => server.passphrase!);
        }

        servers.add(server.copyWith(
          password: decryptedPassword,
          privateKey: decryptedKey,
          passphrase: decryptedPassphrase,
        ));
      }
      return Success(servers);
    } catch (e, st) {
      AppLogger.instance.error('LocalStorage', 'Failed to read servers: $e', e, st);
      return Failure('Corrupted servers configuration', e, st);
    }
  }

  /// Saves servers with sensitive fields encrypted at rest and schemaVersion: 1.
  Future<Result<void>> saveServers(List<ServerEntity> servers) async {
    try {
      final file = await _serversFile;
      final encryptedJsonList = <Map<String, dynamic>>[];

      for (final server in servers) {
        String? encPassword;
        if (server.password != null && server.password!.isNotEmpty) {
          final res = await _vault.encrypt(server.password!);
          if (res.isFailure) {
            final f = res as Failure<String>;
            AppLogger.instance.error(
              'LocalStorage',
              'Refusing to save server "${server.name}": password encryption failed: ${f.message}',
            );
            return Failure(
              'Refusing to persist credentials in plaintext for "${server.name}": password encryption failed: ${f.message}',
              f.exception,
              f.stackTrace,
            );
          }
          encPassword = (res as Success<String>).data;
        }
        String? encKey;
        if (server.privateKey != null && server.privateKey!.isNotEmpty) {
          final res = await _vault.encrypt(server.privateKey!);
          if (res.isFailure) {
            final f = res as Failure<String>;
            AppLogger.instance.error(
              'LocalStorage',
              'Refusing to save server "${server.name}": private key encryption failed: ${f.message}',
            );
            return Failure(
              'Refusing to persist credentials in plaintext for "${server.name}": private key encryption failed: ${f.message}',
              f.exception,
              f.stackTrace,
            );
          }
          encKey = (res as Success<String>).data;
        }
        String? encPassphrase;
        if (server.passphrase != null && server.passphrase!.isNotEmpty) {
          final res = await _vault.encrypt(server.passphrase!);
          if (res.isFailure) {
            final f = res as Failure<String>;
            AppLogger.instance.error(
              'LocalStorage',
              'Refusing to save server "${server.name}": passphrase encryption failed: ${f.message}',
            );
            return Failure(
              'Refusing to persist credentials in plaintext for "${server.name}": passphrase encryption failed: ${f.message}',
              f.exception,
              f.stackTrace,
            );
          }
          encPassphrase = (res as Success<String>).data;
        }

        encryptedJsonList.add(server.copyWith(
          password: encPassword,
          privateKey: encKey,
          passphrase: encPassphrase,
        ).toJson());
      }

      final payload = {
        'schemaVersion': 1,
        'data': encryptedJsonList,
      };

      await _atomicWrite(file, const JsonEncoder.withIndent('  ').convert(payload));
      return const Success(null);
    } catch (e, st) {
      AppLogger.instance.error('LocalStorage', 'Failed to save servers: $e', e, st);
      return Failure('Failed to persist servers', e, st);
    }
  }

  /// Loads known SSH host fingerprints map.
  Future<Map<String, String>> loadKnownHosts() async {
    final file = await _knownHostsFile;
    if (!await file.exists()) return {};
    try {
      final content = await file.readAsString();
      final Map<String, dynamic> rawMap = jsonDecode(content);
      return rawMap.map((k, v) => MapEntry(k, v.toString()));
    } catch (e, st) {
      AppLogger.instance.error('LocalStorage', 'Failed to load known hosts: $e', e, st);
      return {};
    }
  }

  /// Saves known SSH host fingerprint.
  Future<void> saveKnownHost(String hostPortKey, String fingerprint) => _enqueueWrite(() async {
    final knownHosts = await loadKnownHosts();
    knownHosts[hostPortKey] = fingerprint;
    final file = await _knownHostsFile;
    await _atomicWriteLocked(file, const JsonEncoder.withIndent('  ').convert(knownHosts));
  });

  /// Loads activity logs.
  Future<List<ActivityLogEntity>> loadActivityLogs({int limit = 200}) async {
    final file = await _activityFile;
    if (!await file.exists()) {
      final bakFile = File('${file.path}.bak');
      if (await bakFile.exists()) {
        try {
          final content = await bakFile.readAsString();
          final List<dynamic> jsonList = jsonDecode(content);
          final logs = jsonList.map((e) => ActivityLogEntity.fromJson(e as Map<String, dynamic>)).toList();
          return logs.reversed.take(limit).toList();
        } catch (bakErr) {
          AppLogger.instance.warn('LocalStorage', 'Failed to read backup activity logs: $bakErr');
        }
      }
      return [];
    }
    try {
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      final logs = jsonList.map((e) => ActivityLogEntity.fromJson(e as Map<String, dynamic>)).toList();
      return logs.reversed.take(limit).toList();
    } catch (e, st) {
      AppLogger.instance.error('LocalStorage', 'Failed to load activity logs: $e', e, st);
      return [];
    }
  }

  /// Appends an activity log item with 1000 item rolling window.
  Future<void> appendActivityLog(ActivityLogEntity log) => _enqueueWrite(() async {
    final file = await _activityFile;
    final List<ActivityLogEntity> logs = [];
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        logs.addAll(jsonList.map((e) => ActivityLogEntity.fromJson(e as Map<String, dynamic>)));
      } catch (e) {
        AppLogger.instance.warn('LocalStorage', 'Corrupted activity log entries ignored: $e');
      }
    }
    logs.add(log);
    final trimmed = logs.length > 1000 ? logs.sublist(logs.length - 1000) : logs;
    await _atomicWriteLocked(file, const JsonEncoder.withIndent('  ').convert(trimmed.map((e) => e.toJson()).toList()));
  });

  /// Clears all stored activity logs.
  Future<void> clearActivityLogs() => _enqueueWrite(() async {
    final file = await _activityFile;
    if (await file.exists()) {
      await file.delete();
    }
    final bakFile = File('${file.path}.bak');
    if (await bakFile.exists()) {
      try {
        await bakFile.delete();
      } catch (bakDelErr) {
        AppLogger.instance.warn('LocalStorage', 'Failed to delete backup activity file: $bakDelErr');
      }
    }
  });

  Future<File> get _tunnelsFile async => File(p.join((await _storageDirectory).path, 'tunnels.json'));

  /// Loads all configured port forwarding tunnels.
  Future<Result<List<TunnelEntity>>> loadTunnels() async {
    final file = await _tunnelsFile;
    if (!await file.exists()) return const Success([]);
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return const Success([]);
      final List<dynamic> list = jsonDecode(content);
      return Success(list.map((e) => TunnelEntity.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e, st) {
      AppLogger.instance.error('LocalStorage', 'Failed to load tunnels: $e', e, st);
      return Failure('Corrupted tunnels file', e, st);
    }
  }

  /// Saves tunnels configuration.
  Future<Result<void>> saveTunnels(List<TunnelEntity> tunnels) async {
    try {
      final file = await _tunnelsFile;
      final payload = tunnels.map((t) => t.toJson()).toList();
      await _atomicWrite(file, const JsonEncoder.withIndent('  ').convert(payload));
      return const Success(null);
    } catch (e, st) {
      AppLogger.instance.error('LocalStorage', 'Failed to save tunnels: $e', e, st);
      return Failure('Failed to persist tunnels', e, st);
    }
  }
}
