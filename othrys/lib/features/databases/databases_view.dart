import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'database_controller.dart';
import 'widgets/database_create_dialog.dart';
import 'widgets/database_list_tab.dart';
import 'widgets/database_query_tab.dart';
import 'widgets/database_user_dialog.dart';
import 'widgets/database_users_tab.dart';

/// Presentation view for managing remote database engines, databases, users, and queries.
class DatabasesView extends ConsumerStatefulWidget {
  const DatabasesView({super.key});

  @override
  ConsumerState<DatabasesView> createState() => _DatabasesViewState();
}

class _DatabasesViewState extends ConsumerState<DatabasesView> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  void _initData() {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session != null) {
      ref.read(databasesControllerProvider.notifier).refresh(session.sessionId);
    }
  }

  void _openCreateDatabaseDialog(String sessionId) async {
    final server = ref.read(serverControllerProvider).activeSession?.server;
    final engine = ref.read(databasesControllerProvider).selectedEngine;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => DatabaseCreateDialog(
        sessionId: sessionId,
        server: server,
        engine: engine,
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

  void _openCreateUserDialog(String sessionId) async {
    final server = ref.read(serverControllerProvider).activeSession?.server;
    final state = ref.read(databasesControllerProvider);

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => DatabaseUserDialog(
        sessionId: sessionId,
        server: server,
        engine: state.selectedEngine,
        availableDatabases: state.databases.map((d) => d.name).toList(),
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
      child: _buildDatabasesPage(context),
    );
  }

  Widget _buildDatabasesPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession;
    final priv = activeSession?.privileges;
    final canManage = priv == null || priv.canManageSystem;
    final dbState = ref.watch(databasesControllerProvider);
    final sessionId = activeSession?.sessionId ?? '';

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.dbTitle, style: AppTypo.titleLarge(context)),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canManage && dbState.isCurrentEngineInstalled) ...[
              FilledButton(
                onPressed: sessionId.isEmpty ? null : () => _openCreateDatabaseDialog(sessionId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add, size: AppIconSize.xs),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.dbCreate),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Button(
                onPressed: sessionId.isEmpty ? null : () => _openCreateUserDialog(sessionId),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.add_friend, size: AppIconSize.xs),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.dbUserCreate),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (dbState.isLoading && (dbState.databases.isNotEmpty || dbState.users.isNotEmpty))
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
                  : () => ref.read(databasesControllerProvider.notifier).refresh(sessionId),
            ),
          ],
        ),
      ),
      content: dbState.isLoading && dbState.databases.isEmpty && dbState.users.isEmpty
          ? const Center(child: ProgressRing())
          : !dbState.isCurrentEngineInstalled
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InfoBar(
                    title: Text(context.l10n.dbNotInstalled(dbState.selectedEngine.label)),
                    severity: InfoBarSeverity.warning,
                    isLong: true,
                  ),
                )
              : Column(
                  children: [
                    // Subtabs
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated(context),
                        border: Border(bottom: BorderSide(color: AppColors.surfaceBorder(context))),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(0, context.l10n.dbTabDatabases, FluentIcons.database),
                          _buildTabButton(1, context.l10n.dbTabUsers, FluentIcons.permissions),
                          _buildTabButton(2, context.l10n.dbTabQuery, FluentIcons.code),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SizedBox(
                              width: 140,
                              child: ComboBox<DatabaseEngineType>(
                                value: dbState.selectedEngine,
                                items: DatabaseEngineType.values
                                    .map((e) => ComboBoxItem(
                                          value: e,
                                          child: Text(e.label),
                                        ))
                                    .toList(),
                                onChanged: (engine) {
                                  if (engine != null && sessionId.isNotEmpty) {
                                    ref.read(databasesControllerProvider.notifier).selectEngine(engine, sessionId);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab Body
                    Expanded(
                      child: IndexedStack(
                        index: _currentTabIndex,
                        children: [
                          DatabaseListTab(
                            sessionId: sessionId,
                            server: activeSession?.server,
                            canManage: canManage,
                          ),
                          DatabaseUsersTab(
                            sessionId: sessionId,
                            server: activeSession?.server,
                            canManage: canManage,
                          ),
                          DatabaseQueryTab(sessionId: sessionId),
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
              color: isSelected ? AppColors.brandBlue : Colors.transparent,
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
              color: isSelected ? AppColors.brandBlue : AppColors.textMuted(context),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypo.bodySmall(context).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.brandBlue : AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
