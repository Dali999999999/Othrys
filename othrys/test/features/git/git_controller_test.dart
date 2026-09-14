import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/features/git/git_controller.dart';

void main() {
  group('GitController - Parsers', () {
    test('parsePorcelainStatus correctly classifies modified, untracked, deleted, added', () {
      const output = '''
 M lib/main.dart
?? test/new_test.dart
 D lib/old_file.dart
A  lib/feature.dart
R  lib/moved.dart
''';
      final results = GitController.parsePorcelainStatus(output);
      expect(results.length, 5);

      expect(results[0].path, 'lib/main.dart');
      expect(results[0].type, GitChangeType.modified);

      expect(results[1].path, 'test/new_test.dart');
      expect(results[1].type, GitChangeType.untracked);

      expect(results[2].path, 'lib/old_file.dart');
      expect(results[2].type, GitChangeType.deleted);

      expect(results[3].path, 'lib/feature.dart');
      expect(results[3].type, GitChangeType.added);

      expect(results[4].path, 'lib/moved.dart');
      expect(results[4].type, GitChangeType.renamed);
    });

    test('parseAheadBehind parses left-right commit counts', () {
      expect(GitController.parseAheadBehind('0 0'), (ahead: 0, behind: 0));
      expect(GitController.parseAheadBehind('3 7\n'), (ahead: 3, behind: 7));
      expect(GitController.parseAheadBehind('invalid'), (ahead: 0, behind: 0));
    });

    test('parseBranches extracts local and remote branches correctly', () {
      const output = '''
* main
  develop
  feature/auth
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
  remotes/origin/develop
  remotes/origin/feature/auth
''';
      final res = GitController.parseBranches(output);
      expect(res.local, ['main', 'develop', 'feature/auth']);
      expect(res.remote, ['origin/main', 'origin/develop', 'origin/feature/auth']);
    });

    test('parseCommits parses tab-separated git log format', () {
      const output = '''
a1b2c3d	Alice	2 hours ago	feat: implement git management
e4f5g6h	Bob	2 days ago	fix: resolve database connection timeout
i7j8k9l	Charlie	1 week ago	chore(deps): update dependencies
''';
      final commits = GitController.parseCommits(output);
      expect(commits.length, 3);

      expect(commits[0].hash, 'a1b2c3d');
      expect(commits[0].author, 'Alice');
      expect(commits[0].date, '2 hours ago');
      expect(commits[0].message, 'feat: implement git management');

      expect(commits[1].hash, 'e4f5g6h');
      expect(commits[1].author, 'Bob');

      expect(commits[2].hash, 'i7j8k9l');
      expect(commits[2].message, 'chore(deps): update dependencies');
    });

    test('parseDiscoveredRepos strips trailing .git and dedupes paths', () {
      const output = '''
/var/www/my-app/.git
/home/deployer/api/.git/
/opt/backend/.git
/var/www/my-app/.git
''';
      final repos = GitController.parseDiscoveredRepos(output);
      expect(repos, [
        '/var/www/my-app',
        '/home/deployer/api',
        '/opt/backend',
      ]);
    });
  });
}
