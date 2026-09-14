import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/docker_container_entity.dart';
import '../../../shared/widgets/app_status_dot.dart';

/// Single-responsibility widget rendering an individual Docker container list tile
/// with operational actions (Logs, Restart, Start/Stop, Remove).
class DockerContainerTile extends StatelessWidget {
  final DockerContainerEntity container;
  final VoidCallback onViewLogs;
  final ValueChanged<String> onAction;
  final bool canManage;

  const DockerContainerTile({
    super.key,
    required this.container,
    required this.onViewLogs,
    required this.onAction,
    this.canManage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = container.isRunning;

    return ListTile.selectable(
      leading: AppStatusDot(
        variant: isRunning ? StatusDotVariant.success : StatusDotVariant.inactive,
      ),
      title: Text(
        container.names,
        style: AppTypo.body(context).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        '${container.image}  •  ${container.status}  •  ${container.ports}',
        style: AppTypo.micro(context).copyWith(color: AppColors.textMuted(context)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(
            onPressed: onViewLogs,
            child: Text(context.l10n.dockerLogs),
          ),
          if (canManage) ...[
            const SizedBox(width: AppSpacing.sm),
            Button(
              onPressed: () => onAction('restart'),
              child: Text(context.l10n.dockerRestart),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isRunning)
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppColors.warning),
                ),
                onPressed: () => onAction('stop'),
                child: Text(context.l10n.dockerStop),
              )
            else
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppColors.success),
                ),
                onPressed: () => onAction('start'),
                child: Text(context.l10n.dockerStart),
              ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(
                FluentIcons.delete,
                size: AppIconSize.md,
                color: AppColors.danger,
              ),
              onPressed: () => onAction('rm'),
            ),
          ],
        ],
      ),
    );
  }
}
