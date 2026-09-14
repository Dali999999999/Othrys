import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';
import 'encryption_vault.dart';

/// Verification status of a remote host SSH fingerprint.
enum HostKeyStatus {
  trusted,
  unknown,
  changed,
}

/// Trust-On-First-Use (TOFU) host key store.
///
/// Encrypts known SSH fingerprints at rest to prevent MITM tampering and spoofing.
class HostKeyStore {
  final Future<Directory> Function() _getStorageDir;
  final EncryptionVault _vault;
  Map<String, String>? _cache;

  HostKeyStore({
    Future<Directory> Function()? getStorageDir,
    EncryptionVault? vault,
  })  : _getStorageDir = getStorageDir ?? getApplicationSupportDirectory,
        _vault = vault ?? EncryptionVault.instance;

  Future<File> get _file async {
    final baseDir = await _getStorageDir();
    final dir = Directory(p.join(baseDir.path, 'Othrys'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(dir.path, 'known_hosts.json'));
  }

  Future<Map<String, String>> _load() async {
    if (_cache != null) return _cache!;
    final file = await _file;
    if (!await file.exists()) {
      _cache = {};
      return _cache!;
    }

    try {
      final rawCipher = await file.readAsString();
      if (rawCipher.trim().isEmpty) {
        _cache = {};
        return _cache!;
      }

      final decResult = await _vault.decrypt(rawCipher.trim());
      if (decResult.isFailure) {
        _cache = {};
        return _cache!;
      }

      final Map<String, dynamic> jsonMap = jsonDecode(decResult.getOrThrow());
      _cache = jsonMap.map((k, v) => MapEntry(k, v.toString()));
      return _cache!;
    } catch (e, st) {
      AppLogger.instance.error('HostKeyStore', 'Failed to read known hosts: $e', e, st);
      _cache = {};
      return _cache!;
    }
  }

  Future<void> _save() async {
    if (_cache == null) return;
    final file = await _file;
    final jsonStr = jsonEncode(_cache);
    final encResult = await _vault.encrypt(jsonStr);
    if (encResult.isSuccess) {
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(encResult.getOrThrow(), flush: true);
      if (await file.exists()) {
        await file.delete();
      }
      await tmp.rename(file.path);
    }
  }

  /// Preloads the encrypted known hosts into memory cache.
  Future<Map<String, String>> load() async => _load();

  /// Synchronously verifies the fingerprint against the in-memory known hosts cache.
  HostKeyStatus verifyHostKeySync(String host, int port, String fingerprint) {
    final hosts = _cache ?? {};
    final key = '$host:$port';
    final known = hosts[key];
    if (known == null) return HostKeyStatus.unknown;
    if (known == fingerprint) return HostKeyStatus.trusted;
    return HostKeyStatus.changed;
  }

  /// Verifies the SSH fingerprint for a given host and port.
  Future<HostKeyStatus> verifyHostKey(String host, int port, String fingerprint) async {
    final hosts = await _load();
    final key = '$host:$port';
    final known = hosts[key];

    if (known == null) {
      return HostKeyStatus.unknown;
    } else if (known == fingerprint) {
      return HostKeyStatus.trusted;
    } else {
      return HostKeyStatus.changed;
    }
  }

  /// Trusts and securely stores the SSH fingerprint for the host.
  Future<void> trustHost(String host, int port, String fingerprint) async {
    final hosts = await _load();
    hosts['$host:$port'] = fingerprint;
    await _save();
  }

  /// Removes a host from known hosts store.
  Future<void> removeHost(String host, int port) async {
    final hosts = await _load();
    if (hosts.remove('$host:$port') != null) {
      await _save();
    }
  }
}
