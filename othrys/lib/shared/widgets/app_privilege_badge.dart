import 'package:fluent_ui/fluent_ui.dart';
import '../../core/l10n/l10n.dart';
import '../../core/models/user_privileges_entity.dart';
import 'app_badge.dart';

/// Standardized badge displaying remote user privilege role (Root, Sudoer, Standard).
/// Includes rich tooltip with UID and group memberships.
class AppPrivilegeBadge extends StatelessWidget {
  final UserPrivileges privileges;

  const AppPrivilegeBadge({
    super.key,
    required this.privileges,
  });

  @override
  Widget build(BuildContext context) {
    final (label, variant, icon) = switch (privileges.role) {
      UserRole.root => (
          context.l10n.roleRoot,
          AppBadgeVariant.danger,
          FluentIcons.shield_alert,
        ),
      UserRole.sudoer => (
          context.l10n.roleSudoer,
          AppBadgeVariant.info,
          FluentIcons.admin,
        ),
      UserRole.standard => (
          context.l10n.roleStandard,
          AppBadgeVariant.neutral,
          FluentIcons.permissions,
        ),
    };

    final groupsStr = privileges.groups.isEmpty ? '-' : privileges.groups.join(', ');
    final tooltipMessage = 'User: ${privileges.username} (UID: ${privileges.uid})\n'
        'Role: $label\n'
        'Groups: $groupsStr';

    return Tooltip(
      message: tooltipMessage,
      child: AppBadge(
        label: label,
        variant: variant,
        icon: icon,
      ),
    );
  }
}
