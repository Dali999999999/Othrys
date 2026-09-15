import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/utils/shell_utils.dart';

void main() {
  group('ShellUtils', () {
    test('escapeArg wraps simple string in single quotes', () {
      expect(ShellUtils.escapeArg('hello'), "'hello'");
    });

    test('escapeArg properly neutralizes malicious characters and quotes', () {
      expect(ShellUtils.escapeArg("it's cool; rm -rf /"), "'it'\\''s cool; rm -rf /'");
      expect(ShellUtils.escapeArg('arg\$(whoami)`id`'), "'arg\$(whoami)`id`'");
    });

    test('buildSafeCommand builds safely separated single-quoted args', () {
      final cmd = ShellUtils.buildSafeCommand('systemctl', ['status', 'nginx; reboot']);
      expect(cmd, "systemctl 'status' 'nginx; reboot'");
    });

    test('isValidSafePath validates POSIX paths and rejects null bytes or traversal exploits', () {
      expect(ShellUtils.isValidSafePath('/var/log/nginx/access.log'), isTrue);
      expect(ShellUtils.isValidSafePath('relative/path'), isFalse);
      expect(ShellUtils.isValidSafePath('/path/with\x00null'), isFalse);
      expect(ShellUtils.isValidSafePath('/path/with/../traversal'), isFalse);
    });
  });
}
