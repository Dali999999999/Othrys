import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'window/window_titlebar.dart';
import '../features/servers/servers_view.dart';
import '../features/servers/server_controller.dart';
import '../features/terminal/terminal_view.dart';
import '../features/file_manager/file_manager_view.dart';
import '../features/monitoring/monitoring_view.dart';
import '../features/docker/docker_view.dart';
import '../features/services/services_view.dart';
import '../features/databases/databases_view.dart';
import '../features/web_sites/web_sites_view.dart';
import '../features/server_admin/server_admin_view.dart';
import '../features/git/git_view.dart';
import '../features/port_forwarding/tunnels_view.dart';
import '../features/activity/activity_feed_view.dart';
import '../features/command_palette/command_palette_modal.dart';
import '../features/onboarding/welcome_view.dart';
import '../features/settings/settings_view.dart';
import '../features/splash/splash_screen.dart';
import '../core/services/settings_service.dart';
import '../core/services/app_update_service.dart';
import '../core/network/ssh_session_manager.dart';
import '../shared/widgets/app_update_banner.dart';
import '../core/l10n/l10n.dart';

/// Supported root application navigation sections.
enum AppTab {
  servers,
  terminal,
  files,
  git,
  monitoring,
  docker,
  services,
  databases,
  sites,
  security,
  tunnels,
  activity,
  settings;

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AppTab.servers => l10n.navServers,
        AppTab.terminal => l10n.navTerminal,
        AppTab.files => l10n.navFiles,
        AppTab.git => l10n.navGit,
        AppTab.monitoring => l10n.navMonitoring,
        AppTab.docker => l10n.navDocker,
        AppTab.services => l10n.navServices,
        AppTab.databases => l10n.navDatabases,
        AppTab.sites => l10n.navWebSites,
        AppTab.security => l10n.navSecurity,
        AppTab.tunnels => l10n.navTunnels,
        AppTab.activity => l10n.navActivity,
        AppTab.settings => l10n.navSettings,
      };

  String get label => switch (this) {
        AppTab.servers => 'Servers',
        AppTab.terminal => 'Terminal',
        AppTab.files => 'Files',
        AppTab.git => 'Git',
        AppTab.monitoring => 'Monitoring',
        AppTab.docker => 'Docker',
        AppTab.services => 'Services',
        AppTab.databases => 'Databases',
        AppTab.sites => 'Web Sites & SSL',
        AppTab.security => 'Security & Admin',
        AppTab.tunnels => 'Tunnels',
        AppTab.activity => 'Activity',
        AppTab.settings => 'Settings',
      };

  IconData get icon => switch (this) {
        AppTab.servers => FluentIcons.server,
        AppTab.terminal => FluentIcons.command_prompt,
        AppTab.files => FluentIcons.folder_open,
        AppTab.git => FluentIcons.branch_fork,
        AppTab.monitoring => FluentIcons.line_chart,
        AppTab.docker => FluentIcons.package,
        AppTab.services => FluentIcons.developer_tools,
        AppTab.databases => FluentIcons.database,
        AppTab.sites => FluentIcons.globe,
        AppTab.security => FluentIcons.shield,
        AppTab.tunnels => FluentIcons.plug_connected,
        AppTab.activity => FluentIcons.history,
        AppTab.settings => FluentIcons.settings,
      };
}

/// Main Othrys desktop application root widget.
class OthrysApp extends ConsumerStatefulWidget {
  final bool showSplash;

  const OthrysApp({super.key, this.showSplash = true});

  @override
  ConsumerState<OthrysApp> createState() => _OthrysAppState();
}

class _OthrysAppState extends ConsumerState<OthrysApp> {
  late bool _splashFinished;

  @override
  void initState() {
    super.initState();
    _splashFinished = !widget.showSplash;
  }

  void _onSplashComplete() {
    if (mounted) {
      setState(() {
        _splashFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsServiceProvider);

    final targetHome = settings.isFirstLaunch
        ? WelcomeView(onFinish: () {})
        : const MainShellView();

    return FluentApp(
      title: 'Othrys',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _splashFinished
            ? targetHome
            : SplashScreen(
                key: const ValueKey('splash_screen'),
                onAnimationComplete: _onSplashComplete,
              ),
      ),
    );
  }
}

/// Main desktop window layout shell including window titlebar, shortcuts, and sidebar pane.
class MainShellView extends ConsumerStatefulWidget {
  const MainShellView({super.key});

  @override
  ConsumerState<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends ConsumerState<MainShellView> {
  AppTab _selectedTab = AppTab.servers;
  late final ISSHSessionManager _sshManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appUpdateServiceProvider.notifier).checkForUpdate();
    });

    _sshManager = ref.read(sshSessionManagerProvider);
    _sshManager.onHostKeyPrompt = (server, fingerprint) async {
      if (!mounted) return false;
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => ContentDialog(
          title: const Text('SSH Host Key Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The authenticity of host "${server.host}:${server.port}" cannot be established.'),
              const SizedBox(height: 8),
              const Text('Presented Fingerprint (SHA-256):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  fingerprint,
                  style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Do you trust this remote server key and want to continue connecting?'),
            ],
          ),
          actions: [
            Button(
              child: const Text('Reject & Abort'),
              onPressed: () => Navigator.of(dialogCtx).pop(false),
            ),
            FilledButton(
              child: const Text('Trust & Connect'),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
            ),
          ],
        ),
      ) ?? false;
    };
  }

  @override
  void dispose() {
    _sshManager.onHostKeyPrompt = null;
    super.dispose();
  }

  void _navigateToTab(AppTab tab) {
    setState(() => _selectedTab = tab);
  }

  void _openCommandPalette() {
    showDialog(
      context: context,
      builder: (ctx) => CommandPaletteModal(
        onNavigate: (index) {
          if (index >= 0 && index < AppTab.values.length) {
            _navigateToTab(AppTab.values[index]);
          }
        },
      ),
    );
  }

  Widget _buildLazyTabBody(AppTab tab) {
    Widget child = switch (tab) {
      AppTab.servers => ServersView(
          onNavigateToTab: (index) {
            if (index >= 0 && index < AppTab.values.length) {
              _navigateToTab(AppTab.values[index]);
            }
          },
        ),
      AppTab.terminal => const SSHTerminalView(),
      AppTab.files => FileManagerView(
          onNavigateToTab: (index) {
            if (index >= 0 && index < AppTab.values.length) {
              _navigateToTab(AppTab.values[index]);
            }
          },
        ),
      AppTab.git => GitView(
          onNavigateToTab: (index) {
            if (index >= 0 && index < AppTab.values.length) {
              _navigateToTab(AppTab.values[index]);
            }
          },
        ),
      AppTab.monitoring => const MonitoringView(),
      AppTab.docker => const DockerView(),
      AppTab.services => const ServicesView(),
      AppTab.databases => const DatabasesView(),
      AppTab.sites => const WebSitesView(),
      AppTab.security => const ServerAdminView(),
      AppTab.tunnels => const TunnelsView(),
      AppTab.activity => const ActivityFeedView(),
      AppTab.settings => const SettingsView(),
    };

    return TabErrorBoundary(
      tabName: tab.label,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = ref.watch(sshSessionManagerProvider).activeSessionCount;
    final serverState = ref.watch(serverControllerProvider);
    final activeSession = serverState.activeSession;
    final isConnected = serverState.isConnected;

    ref.listen<ServerState>(serverControllerProvider, (previous, next) {
      if (previous?.isConnected == true && !next.isConnected) {
        if (_selectedTab != AppTab.servers && _selectedTab != AppTab.settings) {
          setState(() => _selectedTab = AppTab.servers);
        }
      }
    });

    final visibleTabs = isConnected
        ? AppTab.values.where((t) => t != AppTab.settings).toList()
        : [AppTab.servers];

    final effectiveTab = (isConnected || _selectedTab == AppTab.settings)
        ? _selectedTab
        : AppTab.servers;

    final int selectedIndex;
    if (effectiveTab == AppTab.settings) {
      selectedIndex = visibleTabs.length;
    } else {
      final idx = visibleTabs.indexOf(effectiveTab);
      selectedIndex = idx != -1 ? idx : 0;
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _openCommandPalette,
      },
      child: Focus(
        autofocus: true,
        child: Container(
          color: AppColors.surfaceBase(context),
          child: Column(
            children: [
              WindowTitleBar(
                onCommandPaletteTap: _openCommandPalette,
                activeConnectionsCount: activeCount,
                activePrivileges: activeSession?.privileges,
              ),
              const AppUpdateBanner(),
              Expanded(
                child: NavigationView(
                  pane: NavigationPane(
                    selected: selectedIndex,
                    onChanged: (index) {
                      if (index == visibleTabs.length) {
                        _navigateToTab(AppTab.settings);
                      } else if (index >= 0 && index < visibleTabs.length) {
                        _navigateToTab(visibleTabs[index]);
                      }
                    },
                    displayMode: PaneDisplayMode.compact,
                    items: visibleTabs.map<NavigationPaneItem>((tab) {
                      return PaneItem(
                        icon: Icon(tab.icon),
                        title: Text(tab.localizedLabel(context.l10n)),
                        body: effectiveTab == tab ? _buildLazyTabBody(tab) : const SizedBox.shrink(),
                      );
                    }).toList(),
                    footerItems: [
                      PaneItemSeparator(),
                      PaneItem(
                        icon: Icon(AppTab.settings.icon),
                        title: Text(AppTab.settings.localizedLabel(context.l10n)),
                        body: effectiveTab == AppTab.settings
                            ? _buildLazyTabBody(AppTab.settings)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error boundary isolating view runtime crashes from affecting the global app shell.
class TabErrorBoundary extends StatefulWidget {
  final Widget child;
  final String tabName;

  const TabErrorBoundary({
    super.key,
    required this.child,
    required this.tabName,
  });

  @override
  State<TabErrorBoundary> createState() => _TabErrorBoundaryState();
}

class _TabErrorBoundaryState extends State<TabErrorBoundary> {
  Object? _caughtError;

  @override
  void didUpdateWidget(TabErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabName != widget.tabName) {
      _caughtError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_caughtError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.error_badge, size: AppIconSize.xl, color: AppColors.danger),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.tabErrorTitle(widget.tabName),
                style: AppTypo.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                _caughtError.toString(),
                style: AppTypo.caption(context).copyWith(
                  color: AppColors.textMuted(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Button(
                child: Text(context.l10n.tabErrorReload),
                onPressed: () => setState(() => _caughtError = null),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
