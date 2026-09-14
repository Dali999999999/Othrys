import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dialog_sizes.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/app_shortcut_badge.dart';
import '../servers/server_controller.dart';

/// Single executable item inside the Command Palette.
class PaletteCommandItem {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final String section;
  final VoidCallback onExecute;

  const PaletteCommandItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.section,
    required this.onExecute,
  });
}

/// Modal dialog offering global search and keyboard-driven execution for all actions.
class CommandPaletteModal extends ConsumerStatefulWidget {
  final Function(int tabIndex) onNavigate;

  const CommandPaletteModal({super.key, required this.onNavigate});

  @override
  ConsumerState<CommandPaletteModal> createState() => _CommandPaletteModalState();
}

class _CommandPaletteModalState extends ConsumerState<CommandPaletteModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected(int index) {
    if (_scrollController.hasClients) {
      final target = (index * 48.0).clamp(0.0, _scrollController.position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverControllerProvider);
    final activeSession = serverState.activeSession;
    final servers = serverState.servers;

    final allItems = <PaletteCommandItem>[
      // Dynamic Contextual Actions
      if (activeSession != null)
        PaletteCommandItem(
          id: 'action-disconnect',
          title: context.l10n.cmdPaletteDisconnect,
          subtitle: '${activeSession.server.username}@${activeSession.server.host}',
          icon: FluentIcons.plug_disconnected,
          iconColor: AppColors.danger,
          section: context.l10n.cmdPaletteSectionActions,
          onExecute: () {
            Navigator.of(context).pop();
            ref.read(serverControllerProvider.notifier).disconnectCurrent();
          },
        ),

      // Servers
      ...servers.map((s) {
        return PaletteCommandItem(
          id: 'server-${s.id}',
          title: s.name,
          subtitle: '${s.username}@${s.host}:${s.port}',
          icon: FluentIcons.server,
          iconColor: AppColors.brandCyan,
          section: context.l10n.cmdPaletteSectionServers,
          onExecute: () {
            Navigator.of(context).pop();
            ref.read(serverControllerProvider.notifier).connectToServer(s).then((result) {
              if (result.isSuccess) {
                widget.onNavigate(1); // Go to Terminal
              }
            });
          },
        );
      }),

      // Navigation
      PaletteCommandItem(
        id: 'nav-0',
        title: context.l10n.navServers,
        icon: FluentIcons.server,
        section: context.l10n.cmdPaletteSectionNavigation,
        onExecute: () {
          Navigator.of(context).pop();
          widget.onNavigate(0);
        },
      ),
      if (activeSession != null) ...[
        PaletteCommandItem(
          id: 'nav-1',
          title: context.l10n.navTerminal,
          icon: FluentIcons.command_prompt,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(1);
          },
        ),
        PaletteCommandItem(
          id: 'nav-2',
          title: context.l10n.navFiles,
          icon: FluentIcons.folder_open,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(2);
          },
        ),
        PaletteCommandItem(
          id: 'nav-3',
          title: context.l10n.navGit,
          icon: FluentIcons.branch_fork,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(3);
          },
        ),
        PaletteCommandItem(
          id: 'nav-4',
          title: context.l10n.navMonitoring,
          icon: FluentIcons.line_chart,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(4);
          },
        ),
        PaletteCommandItem(
          id: 'nav-5',
          title: context.l10n.navDocker,
          icon: FluentIcons.package,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(5);
          },
        ),
        PaletteCommandItem(
          id: 'nav-6',
          title: context.l10n.navServices,
          icon: FluentIcons.developer_tools,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(6);
          },
        ),
        PaletteCommandItem(
          id: 'nav-7',
          title: context.l10n.navDatabases,
          icon: FluentIcons.database,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(7);
          },
        ),
        PaletteCommandItem(
          id: 'nav-8',
          title: context.l10n.navWebSites,
          icon: FluentIcons.globe,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(8);
          },
        ),
        PaletteCommandItem(
          id: 'nav-9',
          title: context.l10n.navSecurity,
          icon: FluentIcons.shield,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(9);
          },
        ),
        PaletteCommandItem(
          id: 'nav-10',
          title: context.l10n.navTunnels,
          icon: FluentIcons.plug_connected,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(10);
          },
        ),
        PaletteCommandItem(
          id: 'nav-11',
          title: context.l10n.navActivity,
          icon: FluentIcons.history,
          section: context.l10n.cmdPaletteSectionNavigation,
          onExecute: () {
            Navigator.of(context).pop();
            widget.onNavigate(11);
          },
        ),
      ],
      PaletteCommandItem(
        id: 'nav-11',
        title: context.l10n.navSettings,
        icon: FluentIcons.settings,
        section: context.l10n.cmdPaletteSectionNavigation,
        onExecute: () {
          Navigator.of(context).pop();
          widget.onNavigate(11);
        },
      ),
    ];

    final filteredItems = allItems.where((item) {
      final q = _query.toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          (item.subtitle?.toLowerCase().contains(q) ?? false) ||
          item.section.toLowerCase().contains(q);
    }).toList();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (filteredItems.isNotEmpty) {
              setState(() {
                _selectedIndex = (_selectedIndex + 1) % filteredItems.length;
              });
              _scrollToSelected(_selectedIndex);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (filteredItems.isNotEmpty) {
              setState(() {
                _selectedIndex = (_selectedIndex - 1 + filteredItems.length) % filteredItems.length;
              });
              _scrollToSelected(_selectedIndex);
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (_selectedIndex >= 0 && _selectedIndex < filteredItems.length) {
              filteredItems[_selectedIndex].onExecute();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: ContentDialog(
        title: const SizedBox.shrink(),
        content: SizedBox(
          width: AppDialogSize.standardWidth,
          height: 400,
          child: Column(
            children: [
              TextBox(
                controller: _searchController,
                placeholder: context.l10n.cmdPalettePlaceholder,
                autofocus: true,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(FluentIcons.search, size: AppIconSize.md, color: AppColors.textMuted(context)),
                ),
                suffix: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: AppShortcutBadge(
                    shortcut: context.l10n.cmdPaletteEscToClose,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _query = val;
                    _selectedIndex = 0;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FluentIcons.search,
                              size: AppIconSize.xl,
                              color: AppColors.textFaint(context),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.cmdPaletteNoResults,
                              style: AppTypo.bodySmall(context),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredItems.length,
                        itemBuilder: (ctx, index) {
                          final item = filteredItems[index];
                          final isSelected = index == _selectedIndex;

                          final showSectionHeader = index == 0 ||
                              filteredItems[index - 1].section != item.section;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showSectionHeader)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.sm,
                                    top: AppSpacing.sm,
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    item.section,
                                    style: AppTypo.nano(context).copyWith(
                                      color: AppColors.textFaint(context),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.selectionBackground(AppColors.brandBlue)
                                      : Colors.transparent,
                                  borderRadius: AppRadius.borderSm,
                                  border: isSelected
                                      ? Border.all(color: AppColors.activeBorder(AppColors.brandBlue))
                                      : null,
                                ),
                                child: ListTile.selectable(
                                  leading: Icon(
                                    item.icon,
                                    size: AppIconSize.md,
                                    color: item.iconColor ??
                                        (isSelected ? AppColors.brandBlue : AppColors.textMuted(context)),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: AppTypo.body(context).copyWith(
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                  subtitle: item.subtitle != null
                                      ? Text(
                                          item.subtitle!,
                                          style: AppTypo.micro(context).copyWith(
                                            color: AppColors.textMuted(context),
                                          ),
                                        )
                                      : null,
                                  onPressed: () {
                                    setState(() => _selectedIndex = index);
                                    item.onExecute();
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: const [],
      ),
    );
  }
}
