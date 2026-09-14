import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../web_sites_controller.dart';
import 'ssl_provision_dialog.dart';

/// Card component rendering an individual virtual host configuration.
class WebSiteCard extends ConsumerWidget {
  final WebSiteEntity site;
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const WebSiteCard({
    super.key,
    required this.site,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.webSitesTitle,
      content: context.l10n.webSitesDeleteConfirm(site.domain),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed == true) {
      final res = await ref.read(webSitesControllerProvider.notifier).deleteSite(
            sessionId,
            site,
            server: server,
          );
      if (context.mounted && res.isSuccess) {
        displayInfoBar(
          context,
          builder: (ctx, close) => InfoBar(
            title: Text(context.l10n.commonSuccess),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    }
  }

  void _openSslDialog(BuildContext context) async {
    final success = await showDialog<bool>(
      context: context,
      builder: (ctx) => SslProvisionDialog(
        sessionId: sessionId,
        domain: site.domain,
        server: server,
      ),
    );

    if (success == true && context.mounted) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.commonSuccess),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = ref.watch(webSitesControllerProvider.select(
      (s) => s.pendingDomains.contains(site.domain),
    ));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.surfaceBorder(context)),
      ),
      child: Row(
        children: [
          // Globe / Web Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground(site.hasSsl ? AppColors.success : AppColors.accentCyan),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(
              site.hasSsl ? FluentIcons.lock : FluentIcons.globe,
              size: AppIconSize.md,
              color: site.hasSsl ? AppColors.success : AppColors.accentCyan,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    Text(
                      site.domain,
                      style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                    ),
                    AppBadge(
                      label: site.type.label,
                      variant: AppBadgeVariant.neutral,
                    ),
                    AppBadge(
                      label: site.hasSsl ? context.l10n.webSitesSslActive : context.l10n.webSitesSslInactive,
                      variant: site.hasSsl ? AppBadgeVariant.success : AppBadgeVariant.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  site.type == WebSiteType.reverseProxy
                      ? 'Proxy \u2192 ${site.target}'
                      : 'Root: ${site.target}',
                  style: AppTypo.caption(context).copyWith(
                    fontFamily: AppTypo.fontMono,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (canManage) ...[
            if (!site.hasSsl) ...[
              Tooltip(
                message: context.l10n.webSitesProvisionSsl,
                child: Button(
                  onPressed: isPending ? null : () => _openSslDialog(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.lock, size: AppIconSize.xs),
                      const SizedBox(width: AppSpacing.xs),
                      Text(context.l10n.webSitesProvisionSsl),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],

            // Enable / Disable toggle
            Tooltip(
              message: site.isEnabled ? context.l10n.webSitesDisable : context.l10n.webSitesEnable,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPending) ...[
                    const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2)),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  ToggleSwitch(
                    checked: site.isEnabled,
                    onChanged: isPending
                        ? null
                        : (val) {
                            ref.read(webSitesControllerProvider.notifier).toggleSite(
                                  sessionId,
                                  site,
                                  val,
                                  server: server,
                                );
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Delete
            Tooltip(
              message: context.l10n.commonDelete,
              child: IconButton(
                icon: const Icon(FluentIcons.delete, size: AppIconSize.sm, color: AppColors.danger),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
