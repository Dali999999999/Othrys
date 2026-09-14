import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import '../git/git_controller.dart';
import 'file_manager_controller.dart';
import 'widgets/sftp_address_bar.dart';
import 'widgets/sftp_embedded_terminal.dart';
import 'widgets/sftp_entry_name_dialog.dart';
import 'widgets/sftp_file_editor_dialog.dart';
import 'widgets/sftp_file_list_tile.dart';

/// Presentation view orchestrating the browsing of remote filesystem via SFTP.
class FileManagerView extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const FileManagerView({super.key, this.onNavigateToTab});

  @override
  ConsumerState<FileManagerView> createState() => _FileManagerViewState();
}

class _FileManagerViewState extends ConsumerState<FileManagerView> {
  late final TextEditingController _pathController;
  bool _isManualPathEditing = false;
  bool _isTerminalOpen = false;
  final List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: '.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateTo('.', recordHistory: true);
    });
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  void _navigateTo(String path, {bool recordHistory = true}) {
    final normalized = path.isEmpty || path == '.' ? '/' : path;
    if (recordHistory) {
      if (_historyIndex >= 0 && _historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(normalized);
      _historyIndex = _history.length - 1;
    }
    _loadDirectory(normalized);
  }

  void _loadDirectory(String path) {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session == null) return;
    _pathController.text = path;
    ref.read(fileManagerControllerProvider.notifier).loadDirectory(session.sessionId, path);
  }

  void _navigateBack() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _loadDirectory(_history[_historyIndex]);
      setState(() {});
    }
  }

  void _navigateForward() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _loadDirectory(_history[_historyIndex]);
      setState(() {});
    }
  }

  void _navigateUp() {
    final currentPath = ref.read(fileManagerControllerProvider).currentPath;
    if (currentPath == '/' || currentPath == '.') {
      _navigateTo('/', recordHistory: true);
      return;
    }
    final parent = currentPath.substring(0, currentPath.lastIndexOf('/'));
    _navigateTo(parent.isEmpty ? '/' : parent, recordHistory: true);
  }

  void _openItem(FileEntryEntity item) {
    if (item.isDirectory) {
      _navigateTo(item.path, recordHistory: true);
    } else {
      _openFileEditor(item);
    }
  }

  Future<void> _openFileEditor(FileEntryEntity item) async {
    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    final notifier = ref.read(fileManagerControllerProvider.notifier);
    final readResult = await notifier.readFileContent(session.sessionId, item);

    if (readResult.isFailure && mounted) {
      _showWarning(context.l10n.filesCannotOpen, readResult.failureOrNull?.message ?? 'Read error');
      return;
    }

    final originalContent = readResult.getOrElse(() => '');
    if (!mounted) return;

    final editedContent = await showDialog<String>(
      context: context,
      builder: (ctx) => SftpFileEditorDialog(
        fileName: item.name,
        initialContent: originalContent,
      ),
    );

    if (editedContent != null && mounted) {
      final saveResult = await notifier.writeFileContent(
        session.sessionId,
        item.path,
        editedContent,
        server: server,
      );

      if (saveResult.isSuccess && mounted) {
        displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: Text(context.l10n.commonSuccess),
            content: Text(context.l10n.filesSaveContent),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        });
      } else if (mounted) {
        _showError(context.l10n.commonError, saveResult.failureOrNull?.message ?? 'Save error');
      }
    }
  }

  Future<void> _deleteItem(FileEntryEntity item) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.filesDeleteConfirmTitle,
      content: context.l10n.filesDeleteConfirm(item.name),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed && mounted) {
      final session = ref.read(serverControllerProvider).activeSession;
      final server = ref.read(serverControllerProvider).selectedServer;
      if (session == null) return;

      final result = await ref.read(fileManagerControllerProvider.notifier).deleteEntry(
            session.sessionId,
            item,
            server: server,
          );

      if (result.isFailure && mounted) {
        _showError(context.l10n.commonError, result.failureOrNull?.message ?? 'Deletion failed');
      }
    }
  }

  Future<void> _createNew(bool isDirectory) async {
    final currentPath = ref.read(fileManagerControllerProvider).currentPath;
    final items = ref.read(fileManagerControllerProvider).items;
    final existingNames = items.map((e) => e.name).toList();

    final name = await SftpEntryNameDialog.show(
      context: context,
      title: isDirectory ? context.l10n.filesCreateFolderTitle : context.l10n.filesCreateFileTitle,
      currentPath: currentPath,
      isDirectory: isDirectory,
      isRename: false,
      existingNames: existingNames,
    );

    if (name != null && name.isNotEmpty && mounted) {
      final session = ref.read(serverControllerProvider).activeSession;
      final server = ref.read(serverControllerProvider).selectedServer;
      if (session == null) return;

      final res = await ref.read(fileManagerControllerProvider.notifier).createEntry(
            session.sessionId,
            name,
            isFolder: isDirectory,
            server: server,
          );

      if (res.isFailure && mounted) {
        _showError(context.l10n.commonError, res.failureOrNull?.message ?? 'Creation error');
      }
    }
  }

  Future<void> _uploadFile() async {
    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null || result.files.isEmpty || result.files.first.path == null) return;

    final localPath = result.files.first.path!;
    final file = File(localPath);
    final size = await file.length();

    if (size > 100 * 1024 * 1024) {
      if (mounted) _showWarning(context.l10n.filesUpload, context.l10n.filesUploadLimitExceeded);
      return;
    }

    final fileName = result.files.first.name;
    final currentPath = ref.read(fileManagerControllerProvider).currentPath;
    final remotePath = currentPath == '/' ? '/$fileName' : '$currentPath/$fileName';

    final uploadRes = await ref.read(fileManagerControllerProvider.notifier).uploadFile(
          session.sessionId,
          localPath,
          remotePath,
          server: server,
        );

    if (!mounted) return;
    if (uploadRes.isSuccess) {
      displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: Text(context.l10n.commonSuccess),
          content: Text(context.l10n.filesUploadSuccess(fileName)),
          severity: InfoBarSeverity.success,
          onClose: close,
        );
      });
    } else {
      _showError(context.l10n.commonError, uploadRes.failureOrNull?.message ?? 'Upload failed');
    }
  }

  Future<void> _downloadFile(FileEntryEntity item) async {
    if (item.size > 100 * 1024 * 1024) {
      _showWarning(context.l10n.filesDownload, context.l10n.filesDownloadLimitExceeded);
      return;
    }

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save ${item.name}',
      fileName: item.name,
    );
    if (savePath == null) return;

    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    final res = await ref.read(fileManagerControllerProvider.notifier).downloadFile(
          session.sessionId,
          item,
          savePath,
          server: server,
        );

    if (!mounted) return;
    if (res.isSuccess) {
      displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: Text(context.l10n.commonSuccess),
          content: Text(context.l10n.filesDownloadSuccess(item.name)),
          severity: InfoBarSeverity.success,
          onClose: close,
        );
      });
    } else {
      _showError(context.l10n.commonError, res.failureOrNull?.message ?? 'Download failed');
    }
  }

  Future<void> _renameItem(FileEntryEntity item) async {
    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    final parentDir = item.path.substring(0, item.path.lastIndexOf('/'));
    final effectiveParentDir = parentDir.isEmpty ? '/' : parentDir;
    final items = ref.read(fileManagerControllerProvider).items;
    final existingNames = items.where((e) => e.name != item.name).map((e) => e.name).toList();

    final newName = await SftpEntryNameDialog.show(
      context: context,
      title: context.l10n.filesRenameTitle(item.name),
      currentPath: effectiveParentDir,
      isDirectory: item.isDirectory,
      isRename: true,
      initialName: item.name,
      existingNames: existingNames,
    );

    if (newName != null && newName.isNotEmpty && newName != item.name && mounted) {
      final parentDir = item.path.substring(0, item.path.lastIndexOf('/'));
      final newPath = parentDir.isEmpty ? '/$newName' : '$parentDir/$newName';
      final res = await ref.read(fileManagerControllerProvider.notifier).renameEntry(
            session.sessionId,
            item.path,
            newPath,
            server: server,
          );

      if (res.isFailure && mounted) {
        _showError(context.l10n.commonError, res.failureOrNull?.message ?? 'Rename error');
      }
    }
  }

  void _showWarning(String title, String message) {
    if (!mounted) return;
    displayInfoBar(context, builder: (ctx, close) {
      return InfoBar(title: Text(title), content: Text(message), severity: InfoBarSeverity.warning, onClose: close);
    });
  }

  void _showError(String title, String message) {
    if (!mounted) return;
    displayInfoBar(context, builder: (ctx, close) {
      return InfoBar(title: Text(title), content: Text(message), severity: InfoBarSeverity.error, onClose: close);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.filesGuardMessage,
      child: _buildFileManagerPage(context),
    );
  }

  Widget _buildFileManagerPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession!;
    final fileState = ref.watch(fileManagerControllerProvider);

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.filesHeader(activeSession.server.name)),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fileState.items.any((e) => e.name == '.git')) ...[
              Button(
                onPressed: () async {
                  await ref.read(gitControllerProvider.notifier).addTrackedRepository(
                        activeSession.sessionId,
                        activeSession.server.id,
                        fileState.currentPath,
                      );
                  widget.onNavigateToTab?.call(3);
                },
                child: Row(
                  children: [
                    const Icon(FluentIcons.branch_fork, size: AppIconSize.sm),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.gitOpenFileInManager),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            FilledButton(
              onPressed: _uploadFile,
              child: Row(
                children: [
                  const Icon(FluentIcons.cloud_upload, size: AppIconSize.sm),
                  const SizedBox(width: AppSpacing.xs),
                  Text(context.l10n.filesUpload),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Button(
              onPressed: () => _createNew(false),
              child: Row(
                children: [
                  const Icon(FluentIcons.page_add, size: AppIconSize.sm),
                  const SizedBox(width: AppSpacing.xs),
                  Text(context.l10n.filesNewFile),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Button(
              onPressed: () => _createNew(true),
              child: Row(
                children: [
                  const Icon(FluentIcons.new_folder, size: AppIconSize.sm),
                  const SizedBox(width: AppSpacing.xs),
                  Text(context.l10n.filesNewFolder),
                ],
              ),
            ),
            if (fileState.isLoading && fileState.items.isNotEmpty)
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
              onPressed: () => _loadDirectory(fileState.currentPath),
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          SftpAddressBar(
            currentPath: fileState.currentPath,
            isManualEditing: _isManualPathEditing,
            controller: _pathController,
            canNavigateBack: _historyIndex > 0,
            canNavigateForward: _historyIndex < _history.length - 1,
            canNavigateUp: fileState.currentPath != '/' && fileState.currentPath != '.',
            isTerminalOpen: _isTerminalOpen,
            onNavigateBack: _navigateBack,
            onNavigateForward: _navigateForward,
            onNavigateUp: _navigateUp,
            onRefresh: () => _loadDirectory(fileState.currentPath),
            onNavigate: (path) => _navigateTo(path, recordHistory: true),
            onToggleManualEdit: (val) => setState(() => _isManualPathEditing = val),
            onToggleTerminal: () => setState(() => _isTerminalOpen = !_isTerminalOpen),
            onPathCopied: () {
              displayInfoBar(context, builder: (ctx, close) {
                return InfoBar(
                  title: Text(context.l10n.filesPathCopied),
                  severity: InfoBarSeverity.success,
                  onClose: close,
                );
              });
            },
          ),
          if (fileState.error != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: InfoBar(
                title: Text(context.l10n.filesErrorTitle),
                content: Text(fileState.error!),
                severity: InfoBarSeverity.error,
                action: Button(
                  child: Text(context.l10n.commonRetry),
                  onPressed: () => _loadDirectory(fileState.currentPath),
                ),
              ),
            ),
          Expanded(
            child: fileState.isLoading && fileState.items.isEmpty
                ? const Center(child: ProgressRing())
                : fileState.items.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.filesEmpty,
                          style: AppTypo.bodySmall(context),
                        ),
                      )
                    : ListView.builder(
                        itemCount: fileState.items.length,
                        itemBuilder: (ctx, index) {
                          final item = fileState.items[index];
                          return SftpFileListTile(
                            item: item,
                            onOpen: () => _openItem(item),
                            onDownload: () => _downloadFile(item),
                            onRename: () => _renameItem(item),
                            onDelete: () => _deleteItem(item),
                          );
                        },
                      ),
          ),
          if (_isTerminalOpen)
            SftpEmbeddedTerminal(
              currentPath: fileState.currentPath,
              onClose: () => setState(() => _isTerminalOpen = false),
            ),
        ],
      ),
    );
  }
}
