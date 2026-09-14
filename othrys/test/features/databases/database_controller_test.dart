import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/core/utils/result.dart';
import 'package:vpsmanager/features/databases/database_controller.dart';

class _MockSSHSessionManager extends Fake implements SSHSessionManager {
  final List<String> executedCommands = [];
  String nextCommandOutput = '';
  String nextSafeCommandOutput = '';

  @override
  Future<String> executeCommand(
    String sessionId,
    String command, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    executedCommands.add(command);
    return nextCommandOutput;
  }

  @override
  Future<String> executeSafeCommand(
    String sessionId,
    String baseCommand,
    List<String> arguments, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final full = '$baseCommand ${arguments.join(' ')}';
    executedCommands.add(full);
    return nextSafeCommandOutput;
  }
}

void main() {
  group('DatabaseItem', () {
    test('sizeFormatted converts bytes to human-readable string', () {
      const db1 = DatabaseItem(name: 'test1', sizeBytes: 1048576); // 1 MB
      expect(db1.sizeFormatted, '1.0 MB');

      const db2 = DatabaseItem(name: 'test2', sizeBytes: 512); // 512 B
      expect(db2.sizeFormatted, '512.0 B');

      const dbNull = DatabaseItem(name: 'test3', sizeBytes: null);
      expect(dbNull.sizeFormatted, '0 B');
    });
  });

  group('DatabasesController', () {
    test('probeEngines detects mysql and postgres availability', () async {
      final mock = _MockSSHSessionManager();
      final controller = DatabasesController(sshManager: mock);

      mock.nextCommandOutput = '/usr/bin/mysql';
      await controller.probeEngines('sess-1');

      expect(controller.state.isMysqlInstalled, isTrue);
      expect(controller.state.selectedEngine, DatabaseEngineType.mysql);
    });

    test('loadDatabases parses MySQL tabular schemas output', () async {
      final mock = _MockSSHSessionManager();
      final controller = DatabasesController(sshManager: mock);

      mock.nextSafeCommandOutput =
          'app_prod\tutf8mb4\tutf8mb4_unicode_ci\ninformation_schema\tutf8\tutf8_general_ci\nblog_db\tutf8mb4\tutf8mb4_general_ci\n';

      final res = await controller.loadDatabases('sess-1');

      expect(res, isA<Success<List<DatabaseItem>>>());
      final list = (res as Success<List<DatabaseItem>>).data;
      expect(list.length, 2); // information_schema filtered out
      expect(list[0].name, 'app_prod');
      expect(list[0].charset, 'utf8mb4');
      expect(list[1].name, 'blog_db');
    });

    test('createDatabase and dropDatabase execute safe SQL queries', () async {
      final mock = _MockSSHSessionManager();
      final controller = DatabasesController(sshManager: mock);

      // Create
      final createRes = await controller.createDatabase('sess-1', 'new_store');
      expect(createRes, isA<Success<void>>());
      expect(mock.executedCommands.any((c) => c.contains('CREATE DATABASE `new_store`')), isTrue);

      // Drop
      final dropRes = await controller.dropDatabase('sess-1', 'old_store');
      expect(dropRes, isA<Success<void>>());
      expect(mock.executedCommands.any((c) => c.contains('DROP DATABASE `old_store`')), isTrue);
    });

    test('executeQuery parses tabular TSV result into columns and rows', () async {
      final mock = _MockSSHSessionManager();
      final controller = DatabasesController(sshManager: mock);

      mock.nextSafeCommandOutput = 'id\tusername\temail\n1\talice\talice@test.com\n2\tbob\tbob@test.com\n';

      final res = await controller.executeQuery('sess-1', 'SELECT * FROM users;');

      expect(res, isA<Success<DatabaseQueryResult>>());
      final data = (res as Success<DatabaseQueryResult>).data;
      expect(data.columns, ['id', 'username', 'email']);
      expect(data.rows.length, 2);
      expect(data.rows[0], ['1', 'alice', 'alice@test.com']);
      expect(data.rows[1], ['2', 'bob', 'bob@test.com']);
      expect(data.hasError, isFalse);
    });
  });
}
