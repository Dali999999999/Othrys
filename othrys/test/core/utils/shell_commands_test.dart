import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/utils/shell_commands.dart';

void main() {
  test('ShellCommands.systemOverview uses precise byte metrics', () {
    expect(ShellCommands.systemOverview.contains('free -b'), isTrue);
    expect(ShellCommands.systemOverview.contains('free -g'), isFalse);
    expect(ShellCommands.systemOverview.contains('free -m'), isFalse);
  });

  test('ShellCommands.networkInterfaceStats dynamically parses /proc/net/dev without hardcoded eth0', () {
    expect(ShellCommands.networkInterfaceStats.contains('/proc/net/dev'), isTrue);
    expect(ShellCommands.networkInterfaceStats.contains('eth0'), isFalse);
    expect(ShellCommands.networkInterfaceStats.contains('ens'), isFalse);
  });

  test('ShellCommands.journalctlTail safely formats command', () {
    final cmd = ShellCommands.journalctlTail('nginx.service', lines: 50);
    expect(cmd, "sudo 'journalctl' '-u' 'nginx.service' '-n' '50' '--no-pager'");
  });

  test('ShellCommands.dockerCompose builds safe command with escaped path', () {
    final cmd = ShellCommands.dockerCompose('/opt/my_stack', ['up', '-d']);
    expect(cmd, "cd '/opt/my_stack' && docker-compose 'up' '-d'");
  });
}
