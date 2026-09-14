import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'server_admin_controller.dart';
import 'widgets/firewall_tab.dart';
import 'widgets/listening_ports_tab.dart';
import 'widgets/system_maintenance_tab.dart';
import 'widgets/system_users_tab.dart';

/// Presentation view orchestrating Server Administration & Security.
class ServerAdminView extends ConsumerStatefulWidget {
  const ServerAdminView({super.key});

  @override
  ConsumerState<ServerAdminView> createState() => _ServerAdminViewState();
}

class _ServerAdminViewState extends ConsumerState<ServerAdminView> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  void _initData() {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session != null) {
      ref.read(serverAdminControllerProvider.notifier).refresh(session.sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.servicesGuardMessage,
      child: _buildAdminPage(context),
    );
  }

  Widget _buildAdminPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession;
    final priv = activeSession?.privileges;
    final canManage = priv == null || priv.canManageSystem;
    final state = ref.watch(serverAdminControllerProvider);
    final sessionId = activeSession?.sessionId ?? '';

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.adminTitle, style: AppTypo.titleLarge(context)),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.isLoading && (state.firewall.rules.isNotEmpty || state.users.isNotEmpty))
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ),
            IconButton(
              icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
              onPressed: sessionId.isEmpty
                  ? null
                  : () => ref.read(serverAdminControllerProvider.notifier).refresh(sessionId),
            ),
          ],
        ),
      ),
      content: state.isLoading && state.firewall.rules.isEmpty && state.users.isEmpty
          ? const Center(child: ProgressRing())
          : Column(
              children: [
                // Subtabs Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated(context),
                    border: Border(bottom: BorderSide(color: AppColors.surfaceBorder(context))),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(0, context.l10n.adminTabFirewall, FluentIcons.shield),
                      _buildTabButton(1, context.l10n.adminTabPorts, FluentIcons.network_tower),
                      _buildTabButton(2, context.l10n.adminTabUsers, FluentIcons.contact),
                      _buildTabButton(3, context.l10n.adminTabMaintenance, FluentIcons.repair),
                    ],
                  ),
                ),

                // Tab Content Body
                Expanded(
                  child: IndexedStack(
                    index: _currentTabIndex,
                    children: [
                      FirewallTab(
                        sessionId: sessionId,
                        server: activeSession?.server,
                        canManage: canManage,
                      ),
                      ListeningPortsTab(
                        sessionId: sessionId,
                        server: activeSession?.server,
                        canManage: canManage,
                      ),
                      SystemUsersTab(
                        sessionId: sessionId,
                        server: activeSession?.server,
                        canManage: canManage,
                      ),
                      SystemMaintenanceTab(
                        sessionId: sessionId,
                        server: activeSession?.server,
                        canManage: canManage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.accentCyan : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.xs,
              color: isSelected ? AppColors.accentCyan : AppColors.textMuted(context),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypo.bodySmall(context).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.accentCyan : AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
