import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/utils/logger.dart';
import '../../servers/server_controller.dart';
import '../../terminal/widgets/terminal_tab_view.dart';

/// Embedded interactive bottom terminal panel in SFTP File Manager.
/// Automatically runs `cd <currentPath>` when opened so the prompt is
/// positioned directly inside the active directory.
class SftpEmbeddedTerminal extends ConsumerStatefulWidget {
  final String currentPath;
  final VoidCallback onClose;

  const SftpEmbeddedTerminal({
    super.key,
    required this.currentPath,
    required this.onClose,
  });

  @override
  ConsumerState<SftpEmbeddedTerminal> createState() => _SftpEmbeddedTerminalState();
}

class _SftpEmbeddedTerminalState extends ConsumerState<SftpEmbeddedTerminal> {
  late final xterm.Terminal _terminal;
  late final xterm.TerminalController _controller;
  late final FocusNode _focusNode;
  late final FlyoutController _flyoutController;

  SSHSession? _sshSession;
  StreamSubscription<List<int>>? _stdoutSub;
  StreamSubscription<List<int>>? _stderrSub;
  bool _isConnecting = true;
  String? _errorMessage;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _terminal = xterm.Terminal(maxLines: 5000);
    _controller = xterm.TerminalController();
    _focusNode = FocusNode();
    _flyoutController = FlyoutController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initTerminalSession());
  }

  @override
  void dispose() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    try {
      _sshSession?.close();
    } catch (e) {
      AppLogger.instance.warn('SftpEmbeddedTerminal', 'Error closing embedded SSH session: $e');
    }
    _controller.dispose();
    _focusNode.dispose();
    _flyoutController.dispose();
    super.dispose();
  }

  Future<void> _initTerminalSession() async {
    final activeSession = ref.read(serverControllerProvider).activeSession;
    if (activeSession == null) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = context.l10n.terminalNoConnection;
        });
      }
      return;
    }

    try {
      final session = await activeSession.client.shell(
        pty: const SSHPtyConfig(width: 120, height: 25),
      );
      _sshSession = session;

      _stdoutSub = session.stdout.listen((data) {
        _terminal.write(utf8.decode(data, allowMalformed: true));
      });

      _stderrSub = session.stderr.listen((data) {
        _terminal.write(utf8.decode(data, allowMalformed: true));
      });

      _terminal.onOutput = (data) {
        try {
          session.stdin.add(utf8.encode(data));
        } catch (e) {
          AppLogger.instance.warn('SftpEmbeddedTerminal', 'Error writing to stdin: $e');
        }
      };

      if (mounted) {
        setState(() => _isConnecting = false);
      }

      // Automatically cd to current SFTP directory upon launch
      _cdToCurrentPath();
    } catch (e, st) {
      AppLogger.instance.error('SftpEmbeddedTerminal', 'Failed to open shell: $e', e, st);
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _cdToCurrentPath() {
    final session = _sshSession;
    if (session == null) return;
    final target = widget.currentPath.isEmpty || widget.currentPath == '.' ? '/' : widget.currentPath;
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        session.stdin.add(utf8.encode('cd "$target"\n'));
        _focusNode.requestFocus();
      } catch (e) {
        AppLogger.instance.warn('SftpEmbeddedTerminal', 'Failed to cd: $e');
      }
    });
  }

  void _clearTerminal() {
    _terminal.eraseDisplay();
    try {
      _sshSession?.stdin.add(utf8.encode('clear\n'));
    } catch (_) {}
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final height = _isExpanded ? 380.0 : 230.0;
    final displayPath = widget.currentPath.isEmpty ? '/' : widget.currentPath;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.consoleBackground,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder(context), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Terminal Panel Header
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            color: AppColors.surfaceElevated(context),
            child: Row(
              children: [
                const Icon(
                  FluentIcons.command_prompt,
                  size: AppIconSize.sm,
                  color: AppColors.brandCyan,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.filesTerminalTitle(displayPath),
                    style: AppTypo.caption(context).copyWith(
                      fontFamily: AppTypo.fontMono,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: context.l10n.filesCdHere,
                  child: IconButton(
                    icon: const Icon(FluentIcons.sync_folder, size: AppIconSize.xs),
                    onPressed: _cdToCurrentPath,
                  ),
                ),
                Tooltip(
                  message: context.l10n.terminalClearBuffer,
                  child: IconButton(
                    icon: const Icon(FluentIcons.clear, size: AppIconSize.xs),
                    onPressed: _clearTerminal,
                  ),
                ),
                Tooltip(
                  message: _isExpanded ? context.l10n.commonCollapse : context.l10n.commonExpand,
                  child: IconButton(
                    icon: Icon(
                      _isExpanded ? FluentIcons.collapse_content : FluentIcons.fit_page,
                      size: AppIconSize.xs,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ),
                Tooltip(
                  message: context.l10n.filesCloseTerminal,
                  child: IconButton(
                    icon: const Icon(FluentIcons.cancel, size: AppIconSize.xs),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
          ),

          // Terminal View or Loading / Error state
          Expanded(
            child: _isConnecting
                ? const Center(child: ProgressRing())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: AppTypo.bodySmall(context).copyWith(color: AppColors.danger),
                        ),
                      )
                    : TerminalTabView(
                        terminal: _terminal,
                        controller: _controller,
                        focusNode: _focusNode,
                        flyoutController: _flyoutController,
                        onClear: _clearTerminal,
                      ),
          ),
        ],
      ),
    );
  }
}
