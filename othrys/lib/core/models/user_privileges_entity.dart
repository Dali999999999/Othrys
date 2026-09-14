import 'package:flutter/foundation.dart';

/// Role classification for the connected Linux user.
enum UserRole {
  root,
  sudoer,
  standard,
}

/// Domain entity representing the authenticated Linux user privileges and capabilities
/// on the remote VPS.
@immutable
class UserPrivileges {
  final int uid;
  final String username;
  final List<String> groups;
  final bool canSudoWithoutPassword;

  const UserPrivileges({
    required this.uid,
    required this.username,
    required this.groups,
    required this.canSudoWithoutPassword,
  });

  /// Fallback privileges when probe is unavailable or failed.
  const UserPrivileges.unknown({this.username = 'unknown'})
      : uid = -1,
        groups = const [],
        canSudoWithoutPassword = false;

  /// Whether the authenticated user is the root superuser (UID 0).
  bool get isRoot => uid == 0 || username == 'root';

  /// Whether the user belongs to the 'docker' group, allowing non-root Docker execution.
  bool get hasDockerGroup => groups.contains('docker');

  /// Whether the user can perform system-level operations (systemctl, apt, etc.).
  bool get canManageSystem => isRoot || canSudoWithoutPassword;

  /// Whether the user has permission to interact with the Docker daemon.
  bool get canManageDocker => isRoot || hasDockerGroup || canSudoWithoutPassword;

  /// High-level role for badges and localization.
  UserRole get role {
    if (isRoot) return UserRole.root;
    if (canSudoWithoutPassword) return UserRole.sudoer;
    return UserRole.standard;
  }

  /// Parses the remote output of:
  /// `id -u && id -un && id -Gn && (sudo -n true 2>/dev/null && echo "SUDO:YES" || echo "SUDO:NO")`
  factory UserPrivileges.fromRaw(String rawOutput) {
    final lines = rawOutput
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const UserPrivileges.unknown();
    }

    final parsedUid = int.tryParse(lines[0]) ?? -1;
    final parsedUsername = lines.length > 1 ? lines[1] : 'unknown';
    final parsedGroups = lines.length > 2
        ? lines[2].split(RegExp(r'\s+')).where((g) => g.isNotEmpty).toList()
        : <String>[];
    final hasSudo = lines.any((l) => l.toUpperCase().contains('SUDO:YES'));

    return UserPrivileges(
      uid: parsedUid,
      username: parsedUsername,
      groups: parsedGroups,
      canSudoWithoutPassword: hasSudo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPrivileges &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          username == other.username &&
          listEquals(groups, other.groups) &&
          canSudoWithoutPassword == other.canSudoWithoutPassword;

  @override
  int get hashCode => Object.hash(
        uid,
        username,
        Object.hashAll(groups),
        canSudoWithoutPassword,
      );

  @override
  String toString() =>
      'UserPrivileges(uid: $uid, user: $username, role: $role, canManageSystem: $canManageSystem, canManageDocker: $canManageDocker)';
}
