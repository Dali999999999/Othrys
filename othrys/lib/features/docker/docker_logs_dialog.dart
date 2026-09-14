import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/l10n.dart';
import '../../core/utils/logger.dart';
import '../../shared/widgets/app_status_dot.dart';
import '../../shared/widgets/app_console_box.dart';
import '../servers/server_controller.dart';

/// Modal dialog streaming live container stdout/stderr logs over SSH.
class DockerLogsDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String containerId;
  final String containerName;

  const DockerLogsDialog({
    super.key,
    required this.sessionId,
    required this.containerId,
    required this.containerName,
  });

  static Future<void> show({
    required BuildContext context,
    required String sessionId,
    required String containerId,
    required String containerName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => DockerLogsDialog(
        sessionId: sessionId,
        containerId: containerId,
        containerName: containerName,
      ),
    );
  }

  @override
  ConsumerState<DockerLogsDialog> createState() => _DockerLogsDialogState();
}

class _DockerLogsDialogState extends ConsumerState<DockerLogsDialog> {
  final StringBuffer _buffer = StringBuffer();
  final ScrollController _scrollController = ScrollController();
  SSHSession? _sshSession;
  StreamSubscription<List<int>>? _stdoutSub;
  StreamSubscription<List<int>>? _stderrSub;
  bool _isStreaming = false;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _startStreaming();
  }

  Future<void> _startStreaming() async {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session == null) return;

    setState(() => _isStreaming = true);

    try {
      final channel = await session.client.execute('docker logs -f --tail 200 ${widget.containerId}');
      _sshSession = channel;

      _stdoutSub = channel.stdout.listen((data) {
        _appendLogs(utf8.decode(data, allowMalformed: true));
      });

      _stderrSub = channel.stderr.listen((data) {
        _appendLogs(utf8.decode(data, allowMalformed: true));
      });
    } catch (e, st) {
      AppLogger.instance.error('DockerLogs', 'Error starting live log stream: $e', e, st);
      if (mounted) setState(() => _isStreaming = false);
    }
  }

  void _appendLogs(String text) {
    if (!mounted) return;
    setState(() {
      _buffer.write(text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _stopStreaming() {
    _stdoutSub?.cancel();
    _stderrSub?.cancel();
    _sshSession?.close();
    _stdoutSub = null;
    _stderrSub = null;
    _sshSession = null;
    if (mounted) setState(() => _isStreaming = false);
  }

  void _toggleStreaming() {
    if (_isStreaming) {
      _stopStreaming();
    } else {
      _startStreaming();
    }
  }

  Future<void> _copyLogs() async {
    await Clipboard.setData(ClipboardData(text: _buffer.toString()));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  void dispose() {
    _stopStreaming();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logText = _buffer.toString();

    return ContentDialog(
      title: Row(
        children: [
          Expanded(
            child: Text('${context.l10n.dockerLogs}: ${widget.containerName}'),
          ),
          if (_isStreaming)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppStatusDot(variant: StatusDotVariant.success, pulsing: true),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  context.l10n.dockerLogsStreaming,
                  style: AppTypo.micro(context).copyWith(color: AppColors.success),
                ),
              ],
            ),
        ],
      ),
      content: SizedBox(
        width: AppDialogSize.wideWidth,
        height: AppDialogSize.wideHeight,
        child: logText.isEmpty && _isStreaming
            ? const Center(child: ProgressRing())
            : AppConsoleBox(
                content: logText.isEmpty ? 'No logs recorded.' : logText,
                autoScroll: true,
                scrollController: _scrollController,
              ),
      ),
      actions: [
        Button(
          onPressed: _toggleStreaming,
          child: Text(_isStreaming ? context.l10n.dockerLogsPause : context.l10n.dockerLogsResume),
        ),
        Button(
          onPressed: _copyLogs,
          child: Text(_copied ? context.l10n.commonSuccess : context.l10n.dockerLogsCopy),
        ),
        FilledButton(
          child: Text(context.l10n.commonClose),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
