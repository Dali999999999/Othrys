import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/logger.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'widgets/terminal_tab_view.dart';

/// Single interactive terminal tab with its underlying PTY, controller and subscriptions.
class TerminalTabItem {
  final String id;
  final String title;
  final xterm.Terminal terminal;
  final xterm.TerminalController controller;
  final FocusNode focusNode;
  final FlyoutController flyoutController;
  SSHSession? sshSession;
  StreamSubscription<List<int>>? stdoutSub;
  StreamSubscription<List<int>>? stderrSub;
  Timer? resizeDebounceTimer;

  TerminalTabItem({
    required this.id,
    required this.title,
    required this.terminal,
    required this.controller,
    required this.focusNode,
    required this.flyoutController,
    this.sshSession,
  });

  void resize(int cols, int rows) {
    resizeDebounceTimer?.cancel();
    resizeDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      try {
        sshSession?.resizeTerminal(cols, rows);
      } catch (e) {
        AppLogger.instance.warn('Terminal', 'Error resizing PTY terminal: $e');
      }
    });
  }

  void dispose() {
    resizeDebounceTimer?.cancel();
    stdoutSub?.cancel();
    stderrSub?.cancel();
    try {
      sshSession?.close();
    } catch (e) {
      AppLogger.instance.warn('Terminal', 'Error closing SSH session: $e');
    }
    controller.dispose();
    focusNode.dispose();
    flyoutController.dispose();
  }
}

/// SshTerminalWidget hosting interactive shell tabs connected to the remote VPS.
class SSHTerminalView extends ConsumerStatefulWidget {
  const SSHTerminalView({super.key});

  @override
  ConsumerState<SSHTerminalView> createState() => _SSHTerminalViewState();
}

class _SSHTerminalViewState extends ConsumerState<SSHTerminalView> {
  final List<TerminalTabItem> _tabs = [];
  int _currentIndex = 0;
  bool _isConnecting = false;
  String? _lastServerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndInitTerminal());
  }

  void _checkAndInitTerminal() {
    final activeSession = ref.read(serverControllerProvider).activeSession;
    if (activeSession != null) {
      if (_lastServerId != activeSession.server.id) {
        _closeAllTabs();
        _lastServerId = activeSession.server.id;
      }
      if (_tabs.isEmpty) _addNewTerminalTab();
    }
  }

  void _closeAllTabs() {
    for (final tab in _tabs) {
      tab.dispose();
    }
    _tabs.clear();
    _currentIndex = 0;
  }

  Future<void> _addNewTerminalTab() async {
    final activeSession = ref.read(serverControllerProvider).activeSession;
    if (activeSession == null) return;

    setState(() => _isConnecting = true);

    try {
      final terminal = xterm.Terminal(maxLines: 10000);
      final controller = xterm.TerminalController();
      final focusNode = FocusNode();
      final flyoutController = FlyoutController();
      final tabId = DateTime.now().millisecondsSinceEpoch.toString();

      final tabItem = TerminalTabItem(
        id: tabId,
        title: 'Terminal ${_tabs.length + 1}',
        terminal: terminal,
        controller: controller,
        focusNode: focusNode,
        flyoutController: flyoutController,
      );

      final sshSession = await activeSession.client.shell(
        pty: const SSHPtyConfig(width: 120, height: 35),
      );
      tabItem.sshSession = sshSession;

      tabItem.stdoutSub = sshSession.stdout.listen((data) {
        terminal.write(utf8.decode(data, allowMalformed: true));
      });

      tabItem.stderrSub = sshSession.stderr.listen((data) {
        terminal.write(utf8.decode(data, allowMalformed: true));
      });

      terminal.onOutput = (data) {
        try {
          sshSession.stdin.add(Uint8List.fromList(utf8.encode(data)));
        } catch (e) {
          AppLogger.instance.warn('Terminal', 'Failed to write to SSH stdin: $e');
        }
      };

      terminal.onResize = (w, h, pw, ph) => tabItem.resize(w, h);

      if (mounted) {
        setState(() {
          _tabs.add(tabItem);
          _currentIndex = _tabs.length - 1;
          _isConnecting = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });
      }
    } catch (e, st) {
      AppLogger.instance.error('Terminal', 'Failed to initialize terminal tab: $e', e, st);
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _closeTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      _tabs[index].dispose();
      setState(() {
        _tabs.removeAt(index);
        if (_currentIndex >= _tabs.length) _currentIndex = _tabs.length - 1;
      });
      if (_currentIndex >= 0 && _currentIndex < _tabs.length) {
        _tabs[_currentIndex].focusNode.requestFocus();
      }
    }
  }

  @override
  void dispose() {
    _closeAllTabs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.terminalGuardMessage,
      child: _buildTerminalPage(context),
    );
  }

  Widget _buildTerminalPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession!;

    return ScaffoldPage(
      header: PageHeader(
        title: Text('${activeSession.server.name} — Terminal'),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              onPressed: _addNewTerminalTab,
              child: Row(children: [
                const Icon(FluentIcons.add, size: AppIconSize.sm),
                const SizedBox(width: AppSpacing.xs),
                Text(context.l10n.terminalNewTab),
              ]),
            ),
            const SizedBox(width: AppSpacing.sm),
            Button(
              onPressed: () {
                if (_currentIndex >= 0 && _currentIndex < _tabs.length) {
                  _tabs[_currentIndex].terminal.buffer.clear();
                }
              },
              child: Row(children: [
                const Icon(FluentIcons.clear, size: AppIconSize.sm),
                const SizedBox(width: AppSpacing.xs),
                Text(context.l10n.terminalClearBuffer),
              ]),
            ),
          ],
        ),
      ),
      content: _isConnecting && _tabs.isEmpty
          ? const Center(child: ProgressRing())
          : _tabs.isEmpty
              ? Center(
                  child: Button(
                    onPressed: _addNewTerminalTab,
                    child: Text(context.l10n.terminalOpenSession),
                  ),
                )
              : TabView(
                  currentIndex: _currentIndex.clamp(0, _tabs.length - 1),
                  onChanged: (index) {
                    setState(() => _currentIndex = index);
                    if (index >= 0 && index < _tabs.length) {
                      _tabs[index].focusNode.requestFocus();
                    }
                  },
                  onNewPressed: _addNewTerminalTab,
                  tabs: _tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    return Tab(
                      text: Text(tab.title),
                      icon: const Icon(FluentIcons.command_prompt, size: AppIconSize.sm),
                      onClosed: () => _closeTab(index),
                      body: TerminalTabView(
                        terminal: tab.terminal,
                        controller: tab.controller,
                        focusNode: tab.focusNode,
                        flyoutController: tab.flyoutController,
                        onClear: () => tab.terminal.buffer.clear(),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
