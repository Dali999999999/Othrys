import 'package:flutter/foundation.dart';

/// Semantic action for a firewall rule.
enum FirewallAction {
  allow('ALLOW'),
  deny('DENY'),
  limit('LIMIT'),
  reject('REJECT');

  final String label;
  const FirewallAction(this.label);

  static FirewallAction fromString(String val) {
    final clean = val.toUpperCase().trim();
    if (clean.contains('ALLOW')) return FirewallAction.allow;
    if (clean.contains('DENY')) return FirewallAction.deny;
    if (clean.contains('LIMIT')) return FirewallAction.limit;
    if (clean.contains('REJECT')) return FirewallAction.reject;
    return FirewallAction.allow;
  }
}

/// Traffic direction for a firewall rule.
enum FirewallDirection {
  inbound('IN'),
  outbound('OUT');

  final String label;
  const FirewallDirection(this.label);

  static FirewallDirection fromString(String val) {
    if (val.toUpperCase().contains('OUT')) return FirewallDirection.outbound;
    return FirewallDirection.inbound;
  }
}

/// A parsed UFW rule representation.
@immutable
class FirewallRule {
  final int number;
  final String target;
  final FirewallAction action;
  final FirewallDirection direction;
  final String source;
  final bool isV6;

  const FirewallRule({
    required this.number,
    required this.target,
    required this.action,
    this.direction = FirewallDirection.inbound,
    required this.source,
    this.isV6 = false,
  });
}

/// Global status of the UFW firewall.
@immutable
class FirewallStatus {
  final bool isInstalled;
  final bool isEnabled;
  final String defaultIncoming;
  final String defaultOutgoing;
  final List<FirewallRule> rules;

  const FirewallStatus({
    this.isInstalled = false,
    this.isEnabled = false,
    this.defaultIncoming = 'deny',
    this.defaultOutgoing = 'allow',
    this.rules = const [],
  });

  FirewallStatus copyWith({
    bool? isInstalled,
    bool? isEnabled,
    String? defaultIncoming,
    String? defaultOutgoing,
    List<FirewallRule>? rules,
  }) {
    return FirewallStatus(
      isInstalled: isInstalled ?? this.isInstalled,
      isEnabled: isEnabled ?? this.isEnabled,
      defaultIncoming: defaultIncoming ?? this.defaultIncoming,
      defaultOutgoing: defaultOutgoing ?? this.defaultOutgoing,
      rules: rules ?? this.rules,
    );
  }
}

/// Represents an open / listening network socket.
@immutable
class ListeningPort {
  final String protocol;
  final String localAddress;
  final int port;
  final String? processName;
  final int? pid;

  const ListeningPort({
    required this.protocol,
    required this.localAddress,
    required this.port,
    this.processName,
    this.pid,
  });

  bool get isLoopbackOnly =>
      localAddress.startsWith('127.') || localAddress == '::1' || localAddress == 'localhost';
}

/// Represents a Linux system user account.
@immutable
class LinuxUser {
  final String username;
  final int uid;
  final int gid;
  final String homeDir;
  final String shell;
  final bool isSudoer;
  final List<String> authorizedKeys;

  const LinuxUser({
    required this.username,
    required this.uid,
    required this.gid,
    required this.homeDir,
    required this.shell,
    this.isSudoer = false,
    this.authorizedKeys = const [],
  });

  bool get isSystemDaemon => uid < 1000 && username != 'root';
}

/// Host metadata and pending system updates.
@immutable
class SystemUpdateInfo {
  final int upgradableCount;
  final List<String> upgradablePackages;
  final String hostname;
  final String kernelVersion;
  final String osRelease;
  final String uptime;

  const SystemUpdateInfo({
    this.upgradableCount = 0,
    this.upgradablePackages = const [],
    this.hostname = '',
    this.kernelVersion = '',
    this.osRelease = '',
    this.uptime = '',
  });
}
