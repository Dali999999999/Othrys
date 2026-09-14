import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/utils/result.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'web_sites_controller.dart';
import 'widgets/web_site_card.dart';
import 'widgets/web_site_create_dialog.dart';

/// Presentation view for managing Nginx web sites, reverse proxies, and SSL certificates.
class WebSitesView extends ConsumerStatefulWidget {
  const WebSitesView({super.key});

  @override
  ConsumerState<WebSitesView> createState() => _WebSitesViewState();
}

class _WebSitesViewState extends ConsumerState<WebSitesView> {
  String _searchQuery = '';
  bool _isTestingRenewal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  void _initData() {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session != null) {
      ref.read(webSitesControllerProvider.notifier).loadSites(session.sessionId);
    }
  }

  void _openCreateDialog(String sessionId) async {
    final server = ref.read(serverControllerProvider).activeSession?.server;
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => WebSiteCreateDialog(
        sessionId: sessionId,
        server: server,
      ),
    );

    if (created == true && mounted) {
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

  void _testRenewal(String sessionId) async {
    setState(() => _isTestingRenewal = true);
    final res = await ref.read(webSitesControllerProvider.notifier).testSslRenewal(sessionId);
    if (!mounted) return;
    setState(() => _isTestingRenewal = false);

    if (res is Success<String>) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.commonSuccess),
          content: Text(res.data),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    } else if (res is Failure<String>) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.commonError),
          content: Text(res.message),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.servicesGuardMessage,
      child: _buildWebSitesPage(context),
    );
  }

  Widget _buildWebSitesPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession;
    final priv = activeSession?.privileges;
    final canManage = priv == null || priv.canManageSystem;
    final state = ref.watch(webSitesControllerProvider);
    final sessionId = activeSession?.sessionId ?? '';

    final filtered = state.sites.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.domain.toLowerCase().contains(q) || s.target.toLowerCase().contains(q);
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.webSitesTitle, style: AppTypo.titleLarge(context)),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canManage && state.isNginxInstalled) ...[
              FilledButton(
                onPressed: sessionId.isEmpty ? null : () => _openCreateDialog(sessionId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: AppIconSize.xs),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.webSitesCreate),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Button(
                onPressed: _isTestingRenewal || sessionId.isEmpty ? null : () => _testRenewal(sessionId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isTestingRenewal)
                      const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                    else
                      const Icon(FluentIcons.sync_folder, size: AppIconSize.xs),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.webSitesRenewSsl),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (state.isLoading && state.sites.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2)),
              )
            else
              IconButton(
                icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
                onPressed: sessionId.isEmpty
                    ? null
                    : () => ref.read(webSitesControllerProvider.notifier).loadSites(sessionId),
              ),
          ],
        ),
      ),
      content: state.isLoading && state.sites.isEmpty
          ? const Center(child: ProgressRing())
          : !state.isNginxInstalled
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InfoBar(
                    title: Text(context.l10n.webSitesNginxNotInstalled),
                    severity: InfoBarSeverity.warning,
                    action: canManage
                        ? FilledButton(
                            onPressed: sessionId.isEmpty
                                ? null
                                : () => ref.read(webSitesControllerProvider.notifier).installNginx(sessionId),
                            child: Text(context.l10n.webSitesInstallNginx),
                          )
                        : null,
                    isLong: true,
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 250,
                            child: TextBox(
                              placeholder: context.l10n.commonSearch,
                              prefix: Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.sm),
                                child: Icon(FluentIcons.search, size: AppIconSize.sm, color: AppColors.textMuted(context)),
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filtered.length} ${filtered.length > 1 ? "sites" : "site"}',
                            style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                context.l10n.commonEmpty,
                                style: AppTypo.body(context).copyWith(color: AppColors.textMuted(context)),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (ctx, idx) => WebSiteCard(
                                site: filtered[idx],
                                sessionId: sessionId,
                                server: activeSession?.server,
                                canManage: canManage,
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
