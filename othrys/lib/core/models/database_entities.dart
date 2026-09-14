import 'package:flutter/foundation.dart';

/// Supported database engines on remote Linux VPS.
enum DatabaseEngineType {
  mysql('MySQL / MariaDB', 3306, 'root'),
  postgres('PostgreSQL', 5432, 'postgres');

  final String label;
  final int defaultPort;
  final String defaultUser;

  const DatabaseEngineType(this.label, this.defaultPort, this.defaultUser);
}

/// Metadata representation of a single remote database.
@immutable
class DatabaseItem {
  final String name;
  final String charset;
  final String collation;
  final int? sizeBytes;
  final int? tablesCount;

  const DatabaseItem({
    required this.name,
    this.charset = 'utf8mb4',
    this.collation = '',
    this.sizeBytes,
    this.tablesCount,
  });

  String get sizeFormatted {
    final bytes = sizeBytes;
    if (bytes == null || bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatabaseItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          charset == other.charset;

  @override
  int get hashCode => name.hashCode ^ charset.hashCode;
}

/// Representation of a database user account on the remote engine.
@immutable
class DatabaseUser {
  final String username;
  final String host;
  final bool isSuperuser;
  final List<String> grantedDatabases;

  const DatabaseUser({
    required this.username,
    this.host = '%',
    this.isSuperuser = false,
    this.grantedDatabases = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatabaseUser &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          host == other.host;

  @override
  int get hashCode => username.hashCode ^ host.hashCode;
}

/// Tabular result set from executing an arbitrary SQL query.
@immutable
class DatabaseQueryResult {
  final List<String> columns;
  final List<List<String>> rows;
  final int affectedRows;
  final int executionTimeMs;
  final String? error;

  const DatabaseQueryResult({
    this.columns = const [],
    this.rows = const [],
    this.affectedRows = 0,
    this.executionTimeMs = 0,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;
  bool get isEmpty => rows.isEmpty;
}
