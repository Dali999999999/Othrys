import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';

/// Windows Explorer-style address bar featuring history navigation (Back, Forward, Up),
/// interactive breadcrumb segments, direct manual path editing, copy path shortcut,
/// and embedded terminal toggle.
class SftpAddressBar extends StatelessWidget {
  final String currentPath;
  final bool isManualEditing;
  final TextEditingController controller;
  final bool canNavigateBack;
  final bool canNavigateForward;
  final bool canNavigateUp;
  final bool isTerminalOpen;
  final VoidCallback onNavigateBack;
  final VoidCallback onNavigateForward;
  final VoidCallback onNavigateUp;
  final VoidCallback onRefresh;
  final ValueChanged<String> onNavigate;
  final ValueChanged<bool> onToggleManualEdit;
  final VoidCallback onToggleTerminal;
  final VoidCallback onPathCopied;

  const SftpAddressBar({
    super.key,
    required this.currentPath,
    required this.isManualEditing,
    required this.controller,
    required this.canNavigateBack,
    required this.canNavigateForward,
    required this.canNavigateUp,
    required this.isTerminalOpen,
    required this.onNavigateBack,
    required this.onNavigateForward,
    required this.onNavigateUp,
    required this.onRefresh,
    required this.onNavigate,
    required this.onToggleManualEdit,
    required this.onToggleTerminal,
    required this.onPathCopied,
  });

  void _copyCurrentPath() {
    final path = currentPath.isEmpty ? '/' : currentPath;
    Clipboard.setData(ClipboardData(text: path));
    onPathCopied();
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    final normalized = currentPath == '.' ? '/' : currentPath;
    final segments = normalized.split('/').where((s) => s.isNotEmpty).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HyperlinkButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.hard_drive, size: AppIconSize.sm, color: AppColors.brandCyan),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.filesRootDirectory,
                  style: AppTypo.body(context).copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            onPressed: () => onNavigate('/'),
          ),
          for (int i = 0; i < segments.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Icon(
                FluentIcons.chevron_right,
                size: 8,
                color: AppColors.textMuted(context),
              ),
            ),
            HyperlinkButton(
              child: Text(
                segments[i],
                style: AppTypo.body(context).copyWith(
                  fontWeight: i == segments.length - 1 ? FontWeight.w600 : FontWeight.normal,
                  color: i == segments.length - 1
                      ? AppColors.textPrimary(context)
                      : AppColors.textSecondary(context),
                ),
              ),
              onPressed: () {
                final targetPath = '/${segments.sublist(0, i + 1).join('/')}';
                onNavigate(targetPath);
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Windows Explorer Navigation Controls
          Tooltip(
            message: context.l10n.filesNavigateBack,
            child: IconButton(
              icon: const Icon(FluentIcons.back, size: AppIconSize.md),
              onPressed: canNavigateBack ? onNavigateBack : null,
            ),
          ),
          Tooltip(
            message: context.l10n.filesNavigateForward,
            child: IconButton(
              icon: const Icon(FluentIcons.forward, size: AppIconSize.md),
              onPressed: canNavigateForward ? onNavigateForward : null,
            ),
          ),
          Tooltip(
            message: context.l10n.filesNavigateUp,
            child: IconButton(
              icon: const Icon(FluentIcons.up, size: AppIconSize.md),
              onPressed: canNavigateUp ? onNavigateUp : null,
            ),
          ),
          Tooltip(
            message: context.l10n.commonRefresh,
            child: IconButton(
              icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
              onPressed: onRefresh,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Windows Explorer Address Box
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard(context),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: isManualEditing ? AppColors.brandCyan : AppColors.surfaceBorder(context),
                  width: 1,
                ),
              ),
              child: isManualEditing
                  ? Row(
                      children: [
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(FluentIcons.folder, size: AppIconSize.sm, color: AppColors.brandCyan),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: TextBox(
                            controller: controller,
                            autofocus: true,
                            decoration: WidgetStateProperty.all(const BoxDecoration(color: Colors.transparent)),
                            style: AppTypo.body(context),
                            onSubmitted: (val) {
                              onToggleManualEdit(false);
                              onNavigate(val.trim().isEmpty ? '/' : val.trim());
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(FluentIcons.check_mark, size: AppIconSize.sm),
                          onPressed: () {
                            onToggleManualEdit(false);
                            onNavigate(controller.text.trim().isEmpty ? '/' : controller.text.trim());
                          },
                        ),
                        IconButton(
                          icon: const Icon(FluentIcons.cancel, size: AppIconSize.sm),
                          onPressed: () => onToggleManualEdit(false),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    controller.text = currentPath;
                                    onToggleManualEdit(true);
                                  },
                                ),
                              ),
                              _buildBreadcrumbs(context),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: context.l10n.filesCopyPath,
                          child: IconButton(
                            icon: const Icon(FluentIcons.copy, size: AppIconSize.xs),
                            onPressed: _copyCurrentPath,
                          ),
                        ),
                        Tooltip(
                          message: context.l10n.filesEditPath,
                          child: IconButton(
                            icon: const Icon(FluentIcons.edit, size: AppIconSize.xs),
                            onPressed: () {
                              controller.text = currentPath;
                              onToggleManualEdit(true);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Terminal Toggle Button
          Tooltip(
            message: isTerminalOpen ? context.l10n.filesCloseTerminal : context.l10n.filesOpenTerminal,
            child: Button(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  isTerminalOpen
                      ? AppColors.badgeBackground(AppColors.brandCyan)
                      : AppColors.surfaceCard(context),
                ),
              ),
              onPressed: onToggleTerminal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FluentIcons.command_prompt,
                    size: AppIconSize.sm,
                    color: isTerminalOpen ? AppColors.brandCyan : AppColors.textPrimary(context),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.filesOpenTerminal,
                    style: AppTypo.bodySmall(context).copyWith(
                      fontWeight: isTerminalOpen ? FontWeight.w600 : FontWeight.normal,
                      color: isTerminalOpen ? AppColors.brandCyan : AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
