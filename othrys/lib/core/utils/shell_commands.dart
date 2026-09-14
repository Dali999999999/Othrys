import '../security/command_sanitizer.dart';

/// Pre-configured and parameterized standard Linux server commands.
class ShellCommands {
  ShellCommands._();

  /// System metrics snapshot (uptime, byte-precise memory, root disk space, kernel).
  static const String systemOverview = 'uptime && free -b && df -k / && uname -s -r';

  /// Dynamically detects the first non-loopback network interface metrics.
  static const String networkInterfaceStats =
      r'''awk 'NR>2 {if ($1 !~ /lo:/) {gsub(/:/,""); print $1, $2, $10; exit}}' /proc/net/dev''';

  /// Discovers all containers on the host formatted as single-line JSON.
  static const String dockerPsJson = 'docker ps -a --format "{{json .}}"';

  /// Captures resource consumption for all containers without holding an interactive stream.
  static const String dockerStatsJson = 'docker stats --no-stream --format "{{json .}}"';

  /// Discovers all active/loaded systemd service units without pager truncation.
  static const String systemdServices = 'systemctl list-units --type=service --no-legend --no-pager';

  /// Builds a safe command retrieving recent journalctl logs for a service.
  static String journalctlTail(String serviceUnit, {int lines = 150}) {
    return CommandSanitizer.buildSafeCommand('sudo', [
      'journalctl',
      '-u',
      serviceUnit,
      '-n',
      lines.toString(),
      '--no-pager',
    ]);
  }

  /// Builds a safe docker-compose command scoped to a project folder.
  static String dockerCompose(String directory, List<String> composeArgs) {
    final safeDir = CommandSanitizer.sanitizePath(directory);
    return 'cd $safeDir && ${CommandSanitizer.buildSafeCommand('docker-compose', composeArgs)}';
  }
}
