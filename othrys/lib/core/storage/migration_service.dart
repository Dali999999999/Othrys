import '../security/encryption_vault.dart';

/// Service responsible for incremental local schema migrations.
class MigrationService {
  static const int currentSchemaVersion = 1;
  final EncryptionVault _vault;

  MigrationService({EncryptionVault? vault}) : _vault = vault ?? EncryptionVault.instance;

  /// Migrates server data payload to the latest schema version.
  Future<Map<String, dynamic>> migrateServersJson(dynamic rawJson) async {
    int schemaVersion = 0;
    List<dynamic> serverEntries = [];

    if (rawJson is List) {
      schemaVersion = 0;
      serverEntries = rawJson;
    } else if (rawJson is Map<String, dynamic>) {
      schemaVersion = (rawJson['schemaVersion'] as num?)?.toInt() ?? 0;
      serverEntries = (rawJson['data'] as List<dynamic>?) ?? [];
    }

    if (schemaVersion >= currentSchemaVersion) {
      return rawJson is Map<String, dynamic>
          ? rawJson
          : {'schemaVersion': currentSchemaVersion, 'data': serverEntries};
    }

    // Migration v0 -> v1: Encrypt plaintext credentials if unencrypted
    final migratedServers = <Map<String, dynamic>>[];
    for (final raw in serverEntries) {
      if (raw is! Map<String, dynamic>) continue;
      final server = Map<String, dynamic>.from(raw);

      for (final key in ['password', 'privateKey', 'passphrase']) {
        final val = server[key] as String?;
        if (val != null && val.isNotEmpty && !_vault.isEncrypted(val)) {
          final encResult = await _vault.encrypt(val);
          if (encResult.isSuccess) {
            server[key] = encResult.getOrThrow();
          }
        }
      }
      migratedServers.add(server);
    }

    return {
      'schemaVersion': 1,
      'data': migratedServers,
    };
  }
}
