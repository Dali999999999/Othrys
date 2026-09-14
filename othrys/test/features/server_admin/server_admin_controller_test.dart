import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/core/utils/result.dart';
import 'package:vpsmanager/features/server_admin/server_admin_controller.dart';

class _MockSSHSessionManager extends Fake implements SSHSessionManager {
  final List<String> executedCommands = [];
  String nextCommandOutput = '';

  @override
  Future<String> executeCommand(String sessionId, String command, {bool runInPty = false}) async {
    executedCommands.add(command);
    return nextCommandOutput;
  }
}

void main() {
  group('ServerAdminController - Parsing', () {
    test('parseUfwNumberedRules correctly parses UFW status output', () {
      const sample = '''
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 443                        ALLOW IN    Anywhere
[ 4] 3306/tcp                   DENY IN     Anywhere
[ 5] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
[ 6] 80/tcp (v6)                ALLOW IN    Anywhere (v6)
''';

      final rules = ServerAdminController.parseUfwNumberedRules(sample);
      expect(rules.length, equals(6));

      expect(rules[0].number, equals(1));
      expect(rules[0].target, equals('22/tcp'));
      expect(rules[0].action, equals(FirewallAction.allow));
      expect(rules[0].isV6, isFalse);

      expect(rules[3].number, equals(4));
      expect(rules[3].target, equals('3306/tcp'));
      expect(rules[3].action, equals(FirewallAction.deny));

      expect(rules[4].number, equals(5));
      expect(rules[4].isV6, isTrue);
    });

    test('parseListeningPorts parses ss -tulpn format', () {
      const sample = '''
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
tcp   LISTEN 0      128          0.0.0.0:22         0.0.0.0:*     users:(("sshd",pid=620,fd=3))
tcp   LISTEN 0      511        127.0.0.1:3306       0.0.0.0:*     users:(("mysqld",pid=1102,fd=22))
tcp   LISTEN 0      511          0.0.0.0:80         0.0.0.0:*     users:(("nginx",pid=1450,fd=6))
udp   UNCONN 0      0            0.0.0.0:53         0.0.0.0:*     users:(("systemd-resolve",pid=450,fd=12))
''';

      final ports = ServerAdminController.parseListeningPorts(sample);
      expect(ports.length, equals(4));

      expect(ports[0].protocol, equals('tcp'));
      expect(ports[0].port, equals(22));
      expect(ports[0].processName, equals('sshd'));
      expect(ports[0].pid, equals(620));
      expect(ports[0].isLoopbackOnly, isFalse);

      expect(ports[1].port, equals(3306));
      expect(ports[1].processName, equals('mysqld'));
      expect(ports[1].isLoopbackOnly, isTrue);
    });

    test('parseLinuxUsers parses passwd and group detecting sudo users', () {
      const passwdSample = '''
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
developer:x:1001:1001:Dev User:/home/developer:/bin/zsh
''';

      const groupSample = '''
root:x:0:
sudo:x:27:ubuntu
wheel:x:10:
''';

      final users = ServerAdminController.parseLinuxUsers(passwdSample, groupSample);
      expect(users.length, equals(3)); // root, ubuntu, developer (daemon excluded as non-interactive daemon)

      final rootUser = users.firstWhere((u) => u.username == 'root');
      expect(rootUser.isSudoer, isTrue);

      final ubuntuUser = users.firstWhere((u) => u.username == 'ubuntu');
      expect(ubuntuUser.isSudoer, isTrue);

      final devUser = users.firstWhere((u) => u.username == 'developer');
      expect(devUser.isSudoer, isFalse);
    });
  });

  group('ServerAdminController - Operations', () {
    late _MockSSHSessionManager mockSsh;
    late ServerAdminController controller;

    setUp(() {
      mockSsh = _MockSSHSessionManager();
      controller = ServerAdminController(mockSsh, null);
    });

    test('addFirewallRule executes standard ufw allow command', () async {
      final res = await controller.addFirewallRule('sess-1', port: '8080', proto: 'tcp', action: 'allow');
      expect(res, isA<Success>());
      expect(mockSsh.executedCommands.any((c) => c.contains('sudo ufw allow 8080/tcp')), isTrue);
    });

    test('deleteFirewallRule executes forced ufw delete', () async {
      final res = await controller.deleteFirewallRule('sess-1', 2);
      expect(res, isA<Success>());
      expect(mockSsh.executedCommands.any((c) => c.contains('sudo ufw delete 2')), isTrue);
    });

    test('deleteSystemUser rejects deleting root account', () async {
      final res = await controller.deleteSystemUser('sess-1', 'root');
      expect(res, isA<Failure>());
      expect((res as Failure).message, contains('Cannot delete root'));
    });

    test('deleteSystemUser executes userdel command for valid user', () async {
      final res = await controller.deleteSystemUser('sess-1', 'developer');
      expect(res, isA<Success>());
      expect(mockSsh.executedCommands.any((c) => c.contains('sudo userdel -r \'developer\'')), isTrue);
    });
  });
}
