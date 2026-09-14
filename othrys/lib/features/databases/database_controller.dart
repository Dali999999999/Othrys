import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/database_entities.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/security/command_sanitizer.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/database_entities.dart';

/// State representation for remote database engines, databases, and users.
class DatabasesState {
  final DatabaseEngineType selectedEngine;
  final bool isMysqlInstalled;
  final bool isPostgresInstalled;
  final List<DatabaseItem> databases;
  final List<DatabaseUser> users;
  final DatabaseQueryResult? lastQueryResult;
  final bool isLoading;
  final String? error;

  const DatabasesState({
    this.selectedEngine = DatabaseEngineType.mysql,
    this.isMysqlInstalled = false,
    this.isPostgresInstalled = false,
    this.databases = const [],
    this.users = const [],
    this.lastQueryResult,
    this.isLoading = false,
    this.error,
  });

  bool get isCurrentEngineInstalled =>
      selectedEngine == DatabaseEngineType.mysql ? isMysqlInstalled : isPostgresInstalled;

  DatabasesState copyWith({
    DatabaseEngineType? selectedEngine,
    bool? isMysqlInstalled,
    bool? isPostgresInstalled,
    List<DatabaseItem>? databases,
    List<DatabaseUser>? users,
    DatabaseQueryResult? lastQueryResult,
    bool clearQueryResult = false,
    bool? isLoading,
    String? error,
  }) {
    return DatabasesState(
      selectedEngine: selectedEngine ?? this.selectedEngine,
      isMysqlInstalled: isMysqlInstalled ?? this.isMysqlInstalled,
      isPostgresInstalled: isPostgresInstalled ?? this.isPostgresInstalled,
      databases: databases ?? this.databases,
      users: users ?? this.users,
      lastQueryResult: clearQueryResult ? null : (lastQueryResult ?? this.lastQueryResult),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller orchestrating database engines, databases, users, and queries over SSH.
class DatabasesController extends StateNotifier<DatabasesState> {
  final SSHSessionManager sshManager;
  final ActivityService? activityService;

  DatabasesController({
    required this.sshManager,
    this.activityService,
  }) : super(const DatabasesState());

  void selectEngine(DatabaseEngineType engine, String sessionId) {
    state = state.copyWith(selectedEngine: engine, clearQueryResult: true);
    refresh(sessionId);
  }

  /// Probes installed database engines (MySQL/MariaDB, PostgreSQL).
  Future<void> probeEngines(String sessionId) async {
    bool hasMysql = false;
    bool hasPg = false;

    try {
      final mysqlCheck = await sshManager.executeCommand(
        sessionId,
        'which mysql 2>/dev/null || which mariadb 2>/dev/null || true',
      );
      hasMysql = mysqlCheck.trim().isNotEmpty;
    } catch (_) {}

    try {
      final pgCheck = await sshManager.executeCommand(
        sessionId,
        'which psql 2>/dev/null || true',
      );
      hasPg = pgCheck.trim().isNotEmpty;
    } catch (_) {}

    final defaultEngine = hasMysql ? DatabaseEngineType.mysql : (hasPg ? DatabaseEngineType.postgres : state.selectedEngine);

    state = state.copyWith(
      isMysqlInstalled: hasMysql,
      isPostgresInstalled: hasPg,
      selectedEngine: defaultEngine,
    );
  }

  /// Reloads databases and users for the currently selected engine.
  Future<void> refresh(String sessionId, {bool isSilent = false}) async {
    if (!isSilent && state.databases.isEmpty && state.users.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    try {
      await probeEngines(sessionId);
      if (!state.isCurrentEngineInstalled) {
        state = state.copyWith(isLoading: false, databases: [], users: []);
        return;
      }
      await Future.wait([
        loadDatabases(sessionId),
        loadUsers(sessionId),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      final msg = 'Failed to refresh databases: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      state = state.copyWith(isLoading: false, error: msg);
    }
  }

  /// Lists databases from the remote engine.
  Future<Result<List<DatabaseItem>>> loadDatabases(String sessionId) async {
    try {
      final List<DatabaseItem> items = [];

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        const query = "SELECT schema_name, default_character_set_name, default_collation_name FROM information_schema.schemata;";
        final raw = await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', '-N', '-B', '-e', query],
        );

        const ignore = {'information_schema', 'mysql', 'performance_schema', 'sys'};
        for (final line in raw.trim().split('\n')) {
          final parts = line.trim().split('\t');
          if (parts.isNotEmpty && !ignore.contains(parts[0])) {
            items.add(DatabaseItem(
              name: parts[0],
              charset: parts.length > 1 ? parts[1] : 'utf8mb4',
              collation: parts.length > 2 ? parts[2] : '',
            ));
          }
        }
      } else {
        const query = "SELECT datname, pg_encoding_to_char(encoding), datcollate, pg_database_size(datname) FROM pg_database WHERE datistemplate = false;";
        final raw = await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', '-t', '-A', '-F', '|', '-c', query],
        );

        for (final line in raw.trim().split('\n')) {
          final parts = line.trim().split('|');
          if (parts.isNotEmpty && parts[0].isNotEmpty) {
            items.add(DatabaseItem(
              name: parts[0],
              charset: parts.length > 1 ? parts[1] : 'UTF8',
              collation: parts.length > 2 ? parts[2] : '',
              sizeBytes: parts.length > 3 ? int.tryParse(parts[3]) : null,
            ));
          }
        }
      }

      state = state.copyWith(databases: items);
      return Success(items);
    } catch (e, st) {
      final msg = 'Failed to load databases: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Lists users from the remote engine.
  Future<Result<List<DatabaseUser>>> loadUsers(String sessionId) async {
    try {
      final List<DatabaseUser> users = [];

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        const query = "SELECT user, host, Super_priv FROM mysql.user;";
        final raw = await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', '-N', '-B', '-e', query],
        );

        for (final line in raw.trim().split('\n')) {
          final parts = line.trim().split('\t');
          if (parts.isNotEmpty && parts[0].isNotEmpty) {
            users.add(DatabaseUser(
              username: parts[0],
              host: parts.length > 1 ? parts[1] : '%',
              isSuperuser: parts.length > 2 && parts[2].toUpperCase() == 'Y',
            ));
          }
        }
      } else {
        const query = "SELECT usename, usesuper FROM pg_user;";
        final raw = await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', '-t', '-A', '-F', '|', '-c', query],
        );

        for (final line in raw.trim().split('\n')) {
          final parts = line.trim().split('|');
          if (parts.isNotEmpty && parts[0].isNotEmpty) {
            users.add(DatabaseUser(
              username: parts[0],
              isSuperuser: parts.length > 1 && (parts[1] == 't' || parts[1] == 'true'),
            ));
          }
        }
      }

      state = state.copyWith(users: users);
      return Success(users);
    } catch (e, st) {
      final msg = 'Failed to load database users: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Creates a new database with specified charset.
  Future<Result<void>> createDatabase(
    String sessionId,
    String name, {
    String charset = 'utf8mb4',
    ServerEntity? server,
  }) async {
    final prevDatabases = state.databases;
    // Optimistic addition
    state = state.copyWith(
      databases: [
        ...state.databases,
        DatabaseItem(name: name, charset: charset, collation: ''),
      ],
    );
    try {
      final sanitized = CommandSanitizer.sanitizeIdentifier(name);

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        final query = "CREATE DATABASE `$sanitized` CHARACTER SET $charset;";
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', '-e', query],
        );
      } else {
        final pgEncoding = charset == 'utf8mb4' ? 'UTF8' : charset;
        final query = "CREATE DATABASE \"$sanitized\" ENCODING '$pgEncoding';";
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', '-c', query],
        );
      }

      if (server != null) {
        activityService?.logCustomAction(server, 'Created database $name (${state.selectedEngine.name})');
      }

      await loadDatabases(sessionId);
      return const Success(null);
    } catch (e, st) {
      state = state.copyWith(databases: prevDatabases);
      final msg = 'Failed to create database $name: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Drops a database.
  Future<Result<void>> dropDatabase(
    String sessionId,
    String name, {
    ServerEntity? server,
  }) async {
    final prevDatabases = state.databases;
    // Optimistic removal
    state = state.copyWith(
      databases: state.databases.where((d) => d.name != name).toList(),
    );
    try {
      final sanitized = CommandSanitizer.sanitizeIdentifier(name);

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', '-e', "DROP DATABASE `$sanitized`;"],
        );
      } else {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', '-c', "DROP DATABASE \"$sanitized\";"],
        );
      }

      if (server != null) {
        activityService?.logCustomAction(server, 'Dropped database $name (${state.selectedEngine.name})');
      }

      await loadDatabases(sessionId);
      return const Success(null);
    } catch (e, st) {
      state = state.copyWith(databases: prevDatabases);
      final msg = 'Failed to drop database $name: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Creates a new user and grants permissions.
  Future<Result<void>> createUser(
    String sessionId,
    String username,
    String password, {
    String host = '%',
    String? grantDatabase,
    ServerEntity? server,
  }) async {
    final prevUsers = state.users;
    // Optimistic addition
    state = state.copyWith(
      users: [
        ...state.users,
        DatabaseUser(username: username, host: host, isSuperuser: false),
      ],
    );
    try {
      final sanitizedUser = CommandSanitizer.sanitizeIdentifier(username);
      final sanitizedHost = CommandSanitizer.sanitizeIdentifier(host.replaceAll('%', '_wildcard_')).replaceAll('_wildcard_', '%');

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        final escapedPass = password.replaceAll("'", "''");
        final createQuery = "CREATE USER '$sanitizedUser'@'$sanitizedHost' IDENTIFIED BY '$escapedPass';";
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', '-e', createQuery],
        );

        if (grantDatabase != null && grantDatabase.isNotEmpty) {
          final sanitizedDb = CommandSanitizer.sanitizeIdentifier(grantDatabase);
          final grantQuery = "GRANT ALL PRIVILEGES ON `$sanitizedDb`.* TO '$sanitizedUser'@'$sanitizedHost'; FLUSH PRIVILEGES;";
          await sshManager.executeSafeCommand(
            sessionId,
            'sudo',
            ['mysql', '-e', grantQuery],
          );
        }
      } else {
        final escapedPass = password.replaceAll("'", "''");
        final createQuery = "CREATE USER \"$sanitizedUser\" WITH PASSWORD '$escapedPass';";
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', '-c', createQuery],
        );

        if (grantDatabase != null && grantDatabase.isNotEmpty) {
          final sanitizedDb = CommandSanitizer.sanitizeIdentifier(grantDatabase);
          final grantQuery = "GRANT ALL PRIVILEGES ON DATABASE \"$sanitizedDb\" TO \"$sanitizedUser\";";
          await sshManager.executeSafeCommand(
            sessionId,
            'sudo',
            ['-u', 'postgres', 'psql', '-c', grantQuery],
          );
        }
      }

      if (server != null) {
        activityService?.logCustomAction(server, 'Created user $username (${state.selectedEngine.name})');
      }

      await loadUsers(sessionId);
      return const Success(null);
    } catch (e, st) {
      state = state.copyWith(users: prevUsers);
      final msg = 'Failed to create user $username: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Deletes a database user.
  Future<Result<void>> dropUser(
    String sessionId,
    DatabaseUser user, {
    ServerEntity? server,
  }) async {
    final prevUsers = state.users;
    // Optimistic removal
    state = state.copyWith(
      users: state.users.where((u) => u.username != user.username || u.host != user.host).toList(),
    );
    try {
      final sanitizedUser = CommandSanitizer.sanitizeIdentifier(user.username);

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', '-e', "DROP USER '$sanitizedUser'@'${user.host}';"],
        );
      } else {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', '-c', "DROP USER \"$sanitizedUser\";"],
        );
      }

      if (server != null) {
        activityService?.logCustomAction(server, 'Dropped user ${user.username} (${state.selectedEngine.name})');
      }

      await loadUsers(sessionId);
      return const Success(null);
    } catch (e, st) {
      state = state.copyWith(users: prevUsers);
      final msg = 'Failed to drop user ${user.username}: $e';
      AppLogger.instance.error('DatabasesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Executes an arbitrary SQL query and populates tabular results.
  Future<Result<DatabaseQueryResult>> executeQuery(String sessionId, String sql, {String? targetDatabase}) async {
    final sw = Stopwatch()..start();
    try {
      final List<String> columns = [];
      final List<List<String>> rows = [];

      if (state.selectedEngine == DatabaseEngineType.mysql) {
        final dbArg = targetDatabase != null && targetDatabase.isNotEmpty
            ? ['-D', CommandSanitizer.sanitizeIdentifier(targetDatabase)]
            : <String>[];
        final raw = await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['mysql', ...dbArg, '-B', '-e', sql],
        );

        final lines = raw.trim().split('\n');
        if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
          columns.addAll(lines[0].split('\t'));
          for (int i = 1; i < lines.length; i++) {
            final line = lines[i];
            if (line.isNotEmpty) {
              rows.add(line.split('\t'));
            }
          }
        }
      } else {
        final dbArg = targetDatabase != null && targetDatabase.isNotEmpty
            ? ['-d', CommandSanitizer.sanitizeIdentifier(targetDatabase)]
            : <String>[];
        final raw = await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['-u', 'postgres', 'psql', ...dbArg, '-F', '|', '-A', '-c', sql],
        );

        final lines = raw.trim().split('\n');
        if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
          columns.addAll(lines[0].split('|'));
          for (int i = 1; i < lines.length; i++) {
            final line = lines[i];
            // psql outputs summary row like '(X rows)' at the end
            if (line.isNotEmpty && !line.startsWith('(')) {
              rows.add(line.split('|'));
            }
          }
        }
      }

      sw.stop();
      final res = DatabaseQueryResult(
        columns: columns,
        rows: rows,
        affectedRows: rows.length,
        executionTimeMs: sw.elapsedMilliseconds,
      );
      state = state.copyWith(lastQueryResult: res);
      return Success(res);
    } catch (e, st) {
      sw.stop();
      final msg = e.toString();
      final res = DatabaseQueryResult(
        error: msg,
        executionTimeMs: sw.elapsedMilliseconds,
      );
      state = state.copyWith(lastQueryResult: res);
      return Failure(msg, e, st);
    }
  }
}

/// Riverpod provider for databases controller.
final databasesControllerProvider =
    StateNotifierProvider.autoDispose<DatabasesController, DatabasesState>((ref) {
  return DatabasesController(
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});
