import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/utils/logger.dart';
import '../../core/l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../../shared/widgets/app_privilege_badge.dart';
import '../../shared/widgets/app_status_dot.dart';
import '../../shared/widgets/app_shortcut_badge.dart';
import '../../shared/widgets/app_brand_mark.dart';

/// Native Windows titlebar with drag region, quick search, and window controls.
class WindowTitleBar extends StatelessWidget {
  /// Application title displayed in the titlebar.
  final String title;

  /// Callback to trigger the quick command palette modal.
  final VoidCallback? onCommandPaletteTap;

  /// Active SSH connections counter.
  final int activeConnectionsCount;

  /// Active remote user privileges, if any session is selected.
  final UserPrivileges? activePrivileges;

  const WindowTitleBar({
    super.key,
    this.title = 'Othrys',
    this.onCommandPaletteTap,
    this.activeConnectionsCount = 0,
    this.activePrivileges,
  });

  Future<void> _handleWindowClose(BuildContext context) async {
    final activeCount = SSHSessionManager.instance.activeSessions.length;

    if (activeCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => ContentDialog(
          title: Text(context.l10n.windowExitConfirmTitle),
          content: Text(context.l10n.windowExitConfirmMessage(activeCount)),
          actions: [
            Button(
              child: Text(context.l10n.commonCancel),
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.danger),
              ),
              child: Text(context.l10n.windowExitDisconnect),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    try {
      SSHSessionManager.instance.disconnectAll();
      await windowManager.close();
    } catch (e, st) {
      AppLogger.instance.error('Window', 'Error closing window: $e', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;

    return Container(
      height: 38,
      color: AppColors.surfaceBase(context),
      child: Row(
        children: [
          // Drag region covering title & icon
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  const AppBrandMark.titlebar(),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTypo.caption(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  if (activeConnectionsCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm + 2),
                    Container(
                      padding: AppSpacing.badgePadding,
                      decoration: BoxDecoration(
                        color: AppColors.badgeBackground(AppColors.success),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(
                          color: AppColors.badgeBorder(AppColors.success),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppStatusDot(variant: StatusDotVariant.success),
                          const SizedBox(width: 5),
                          Text(
                            context.l10n.windowActiveCount(activeConnectionsCount),
                            style: AppTypo.nano(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (activePrivileges != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    AppPrivilegeBadge(privileges: activePrivileges!),
                  ],
                ],
              ),
            ),
          ),

          // Command Palette quick trigger button
          if (onCommandPaletteTap != null)
            Button(
              onPressed: onCommandPaletteTap,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                ),
                backgroundColor: WidgetStateProperty.all(
                  AppColors.surfaceCard(context),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FluentIcons.search,
                    size: AppIconSize.sm,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.windowSearchActions,
                    style: AppTypo.micro(context).copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  const AppShortcutBadge(shortcut: 'Ctrl+K'),
                ],
              ),
            ),

          const SizedBox(width: AppSpacing.md),

          // Window Caption Buttons (Minimize, Maximize, Close) with adaptive brightness
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WindowCaptionButton.minimize(
                brightness: brightness,
                onPressed: () async {
                  try {
                    if (await windowManager.isMinimized()) {
                      await windowManager.restore();
                    } else {
                      await windowManager.minimize();
                    }
                  } catch (e) {
                    AppLogger.instance.warn('Window', 'Minimize failed: $e');
                  }
                },
              ),
              WindowCaptionButton.maximize(
                brightness: brightness,
                onPressed: () async {
                  try {
                    if (await windowManager.isMaximized()) {
                      await windowManager.unmaximize();
                    } else {
                      await windowManager.maximize();
                    }
                  } catch (e) {
                    AppLogger.instance.warn('Window', 'Maximize failed: $e');
                  }
                },
              ),
              WindowCaptionButton.close(
                brightness: brightness,
                onPressed: () => _handleWindowClose(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
