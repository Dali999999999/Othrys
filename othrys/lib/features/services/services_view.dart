import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dialog_sizes.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_console_box.dart';
import '../../shared/widgets/app_status_dot.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'services_controller.dart';
import 'widgets/service_create_dialog.dart';

/// Presentation view for inspecting and controlling systemd service units.
class ServicesView extends ConsumerStatefulWidget {
  const ServicesView({super.key});

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView> {
  static const Set<String> criticalServices = {
    'sshd',
    'ssh',
    'networking',
    'systemd-resolved',
    'systemd-networkd',
    'NetworkManager',
    'firewalld',
  };

  String _filter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session != null) {
      ref.read(servicesControllerProvider.notifier).loadServices(session.sessionId);
    }
  }

  Future<void> _handleServiceAction(ServiceEntryEntity service, String action) async {
    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    if (action == 'stop') {
      final isCritical = criticalServices.contains(service.unit.replaceAll('.service', ''));
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: '${context.l10n.servicesStop}: ${service.unit}',
        content: isCritical
            ? context.l10n.servicesConfirmStopCritical(service.unit)
            : context.l10n.servicesConfirmStop(service.unit),
        confirmText: context.l10n.servicesStop,
        isDanger: true,
      );
      if (!confirmed) return;
    } else if (action == 'disable') {
      final isCritical = criticalServices.contains(service.unit.replaceAll('.service', ''));
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: '${context.l10n.servicesDisable}: ${service.unit}',
        content: isCritical
            ? context.l10n.servicesConfirmDisableCritical(service.unit)
            : context.l10n.servicesConfirmDisable(service.unit),
        confirmText: context.l10n.servicesDisable,
        isDanger: isCritical,
      );
      if (!confirmed) return;
    }

    final result = await ref.read(servicesControllerProvider.notifier).executeServiceAction(
          session.sessionId,
          service,
          action,
          server: server,
        );

    if (result.isFailure && mounted) {
      displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: Text(context.l10n.commonError),
          content: Text(result.failureOrNull?.message ?? 'Unknown error'),
          severity: InfoBarSeverity.error,
          onClose: close,
        );
      });
    }
  }

  Future<void> _viewJournalLogs(ServiceEntryEntity service) async {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session == null) return;

    final result = await ref
        .read(servicesControllerProvider.notifier)
        .getJournalLogs(session.sessionId, service.unit, lines: 150);

    if (!mounted) return;

    final logs = result.getOrElse(() => 'No logs available or error reading journal.');

    showDialog(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text('${context.l10n.servicesLogs}: ${service.unit}'),
        content: SizedBox(
          width: AppDialogSize.wideWidth,
          height: AppDialogSize.wideHeight,
          child: AppConsoleBox(
            content: logs.isEmpty ? 'No logs available.' : logs,
            height: AppDialogSize.wideHeight,
          ),
        ),
        actions: [
          Button(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.copy, size: AppIconSize.sm),
                const SizedBox(width: AppSpacing.xs),
                Text(context.l10n.commonCopy),
              ],
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: logs));
              displayInfoBar(context, builder: (c, close) => InfoBar(
                title: Text(context.l10n.commonSuccess),
                content: Text(context.l10n.commonCopied),
                severity: InfoBarSeverity.success,
                onClose: close,
              ));
            },
          ),
          Button(child: Text(context.l10n.commonClose), onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }

  void _openCreateServiceDialog(ActiveSSHSession session) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => ServiceCreateDialog(
        sessionId: session.sessionId,
        server: session.server,
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

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.servicesGuardMessage,
      child: _buildServicesPage(context),
    );
  }

  Widget _buildServicesPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession;
    final priv = activeSession?.privileges;
    final canManageSystem = priv == null || priv.canManageSystem;

    final servicesState = ref.watch(servicesControllerProvider);
    final filtered = servicesState.services.where((s) {
      final q = _filter.toLowerCase();
      return s.unit.toLowerCase().contains(q) || s.description.toLowerCase().contains(q);
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.servicesTitle),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canManageSystem && activeSession != null) ...[
              FilledButton(
                onPressed: () => _openCreateServiceDialog(activeSession),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: AppIconSize.xs, color: Colors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.servicesCreate,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            SizedBox(
              width: 220,
              child: TextBox(
                placeholder: context.l10n.servicesSearchPlaceholder,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(FluentIcons.search, size: AppIconSize.sm, color: AppColors.textMuted(context)),
                ),
                onChanged: (val) => setState(() => _filter = val),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (servicesState.isLoading && servicesState.services.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2)),
              )
            else
              IconButton(
                icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
                onPressed: _refresh,
              ),
          ],
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!canManageSystem) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: InfoBar(
                title: Text(context.l10n.servicesPermissionRestricted(priv.username)),
                severity: InfoBarSeverity.warning,
                isLong: true,
              ),
            ),
          ],
          Expanded(
            child: servicesState.isLoading && servicesState.services.isEmpty
                ? const Center(child: ProgressRing())
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.servicesNoServices,
                          style: AppTypo.bodySmall(context),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, index) {
                          final s = filtered[index];
                          final isRunning = s.isRunning;
                          final isPending = servicesState.pendingUnits.contains(s.unit);

                          return ListTile.selectable(
                            leading: AppStatusDot(
                              variant: isRunning ? StatusDotVariant.success : StatusDotVariant.inactive,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  s.unit,
                                  style: AppTypo.body(context).copyWith(
                                    fontFamily: AppTypo.fontMono,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                if (s.isEnabled)
                                  AppBadge(
                                    label: context.l10n.servicesEnabledBadge,
                                    icon: FluentIcons.check_mark,
                                    variant: AppBadgeVariant.success,
                                  )
                                else
                                  AppBadge(
                                    label: context.l10n.servicesDisabledBadge,
                                    icon: FluentIcons.power_button,
                                    variant: AppBadgeVariant.neutral,
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${s.active} (${s.sub})  •  ${s.description}',
                              style: AppTypo.micro(context).copyWith(color: AppColors.textMuted(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPending) ...[
                                  const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2)),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Button(
                                  child: Text(context.l10n.servicesLogs),
                                  onPressed: () => _viewJournalLogs(s),
                                ),
                                if (canManageSystem) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  Button(
                                    onPressed: isPending ? null : () => _handleServiceAction(s, s.isEnabled ? 'disable' : 'enable'),
                                    child: Text(
                                      s.isEnabled ? context.l10n.servicesDisable : context.l10n.servicesEnable,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Button(
                                    onPressed: isPending ? null : () => _handleServiceAction(s, 'restart'),
                                    child: Text(context.l10n.servicesRestart),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  if (isRunning)
                                    FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(AppColors.danger),
                                      ),
                                      onPressed: isPending ? null : () => _handleServiceAction(s, 'stop'),
                                      child: Text(
                                        context.l10n.servicesStop,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  else
                                    FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty.all(AppColors.success),
                                      ),
                                      onPressed: isPending ? null : () => _handleServiceAction(s, 'start'),
                                      child: Text(
                                        context.l10n.servicesStart,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
