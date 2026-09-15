import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/models/file_entry_entity.dart';
import '../../core/network/is_ssh_session_manager.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/file_entry_entity.dart';

/// State representation for the SFTP directory tree and current path.
class FileManagerState {
  final String currentPath;
  final List<FileEntryEntity> items;
  final bool isLoading;
  final String? error;

  const FileManagerState({
    this.currentPath = '.',
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  FileManagerState copyWith({
    String? currentPath,
    List<FileEntryEntity>? items,
    bool? isLoading,
    String? error,
  }) =>
      FileManagerState(
        currentPath: currentPath ?? this.currentPath,
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

/// Controller managing SFTP operations: navigation, file inspection, downloads, uploads, and deletions.
class FileManagerController extends StateNotifier<FileManagerState> {
  static const int maxTransferBytes = 100 * 1024 * 1024; // 100 MB safety limit
  static const int maxEditableFileBytes = 1024 * 1024; // 1 MB safety limit for inline editing
  static const List<String> binaryExtensions = [
    '.zip', '.tar', '.gz', '.tgz', '.bz2', '.7z', '.bin', '.exe',
    '.iso', '.so', '.dll', '.dylib', '.db', '.sqlite', '.png',
    '.jpg', '.jpeg', '.gif', '.webp', '.ico', '.pdf', '.mp4', '.mkv',
  ];

  final ISSHSessionManager sshManager;
  final ActivityService? activityService;

  FileManagerController({
    required this.sshManager,
    this.activityService,
  }) : super(const FileManagerState());

  /// Checks if a file has a known binary extension.
  static bool isBinary(String filename) {
    final lower = filename.toLowerCase();
    return binaryExtensions.any((ext) => lower.endsWith(ext));
  }

  /// Lists entries inside [path].
  Future<Result<List<FileEntryEntity>>> loadDirectory(
    String sessionId,
    String path, {
    bool isSilent = false,
  }) async {
    if (!isSilent && (state.currentPath != path || state.items.isEmpty)) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    try {
      final sftp = await sshManager.getSftp(sessionId);
      final rawItems = await sftp.listdir(path);

      final filtered = rawItems.where((i) => i.filename != '.').toList()
        ..sort((a, b) {
          final aIsDir = a.attr.isDirectory;
          final bIsDir = b.attr.isDirectory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.filename.toLowerCase().compareTo(b.filename.toLowerCase());
        });

      final entities = filtered.map((i) {
        final filePath = path == '/' ? '/${i.filename}' : '$path/${i.filename}';
        return FileEntryEntity(
          name: i.filename,
          path: filePath,
          isDirectory: i.attr.isDirectory,
          size: i.attr.size ?? 0,
          modifiedTime: i.attr.modifyTime != null
              ? DateTime.fromMillisecondsSinceEpoch(i.attr.modifyTime! * 1000)
              : null,
        );
      }).toList();

      state = state.copyWith(
        currentPath: path,
        items: entities,
        isLoading: false,
      );
      return Success(entities);
    } catch (e, st) {
      final msg = 'Failed to load directory "$path": $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      state = state.copyWith(isLoading: false, error: msg);
      return Failure(msg, e, st);
    }
  }

  /// Safely reads the text content of [item], respecting size and binary format limits.
  Future<Result<String>> readFileContent(String sessionId, FileEntryEntity item) async {
    if (isBinary(item.name)) {
      return const Failure('Opening binary files in text editor is not supported.');
    }
    if (item.size > maxEditableFileBytes) {
      return const Failure('File size exceeds the 1 MB safety limit for inline editing.');
    }

    try {
      final sftp = await sshManager.getSftp(sessionId);
      final file = await sftp.open(item.path);
      final contentBytes = await file.readBytes();
      await file.close();

      final text = utf8.decode(contentBytes, allowMalformed: true);
      return Success(text);
    } catch (e, st) {
      final msg = 'Failed to read file "${item.name}": $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Overwrites [filePath] with [content].
  Future<Result<void>> writeFileContent(
    String sessionId,
    String filePath,
    String content, {
    ServerEntity? server,
  }) async {
    try {
      final sftp = await sshManager.getSftp(sessionId);
      final file = await sftp.open(
        filePath,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate,
      );
      await file.writeBytes(utf8.encode(content));
      await file.close();

      if (server != null) {
        activityService?.logFileAction(server, filePath, 'edit');
      }

      await loadDirectory(sessionId, state.currentPath);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to write file "$filePath": $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Creates a new directory or empty file.
  Future<Result<void>> createEntry(
    String sessionId,
    String name, {
    required bool isFolder,
    ServerEntity? server,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed == '.' ||
        trimmed == '..' ||
        trimmed.contains('/') ||
        trimmed.contains(r'\') ||
        trimmed.contains('\x00')) {
      return const Failure('Invalid entry name. Path traversal and separators are not allowed.');
    }
    final targetPath = state.currentPath == '/' ? '/$trimmed' : '${state.currentPath}/$trimmed';
    try {
      final sftp = await sshManager.getSftp(sessionId);
      if (isFolder) {
        await sftp.mkdir(targetPath);
      } else {
        final file = await sftp.open(targetPath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
        await file.close();
      }

      if (server != null) {
        activityService?.logFileAction(server, targetPath, isFolder ? 'mkdir' : 'create');
      }

      await loadDirectory(sessionId, state.currentPath);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to create $targetPath: $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Deletes a file or directory.
  Future<Result<void>> deleteEntry(
    String sessionId,
    FileEntryEntity item, {
    ServerEntity? server,
  }) async {
    final prevItems = state.items;
    // Optimistic deletion
    state = state.copyWith(
      items: state.items.where((i) => i.path != item.path).toList(),
    );
    try {
      final sftp = await sshManager.getSftp(sessionId);
      if (item.isDirectory) {
        await sftp.rmdir(item.path);
      } else {
        await sftp.remove(item.path);
      }

      if (server != null) {
        activityService?.logFileAction(server, item.path, 'delete');
      }

      await loadDirectory(sessionId, state.currentPath, isSilent: true);
      return const Success(null);
    } catch (e, st) {
      state = state.copyWith(items: prevItems);
      final msg = 'Failed to delete ${item.path}: $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Uploads a local file to remoteDirectory via SFTP.
  Future<Result<void>> uploadFile(
    String sessionId,
    String localPath,
    String remoteDirectory, {
    ServerEntity? server,
    bool overwrite = true,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return Failure('Local file does not exist: $localPath');
      }

      final fileSize = await file.length();
      if (fileSize > maxTransferBytes) {
        return const Failure('File size exceeds the 100 MB upload limit.');
      }

      final fileName = p.basename(localPath);
      if (fileName.isEmpty || fileName == '.' || fileName == '..' || fileName.contains('\x00')) {
        return const Failure('Invalid file name.');
      }
      final remotePath = remoteDirectory == '/' ? '/$fileName' : '$remoteDirectory/$fileName';

      final sftp = await sshManager.getSftp(sessionId);
      if (!overwrite) {
        try {
          await sftp.stat(remotePath);
          return Failure('Remote file already exists: $remotePath');
        } catch (e) {
          // File does not exist, can safely proceed
          AppLogger.instance.debug('FileManagerController', 'Target file does not exist, proceeding with upload: $e');
        }
      }

      final remoteFile = await sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create | SftpFileOpenMode.write | SftpFileOpenMode.truncate,
      );

      final stream = file.openRead().map((chunk) => Uint8List.fromList(chunk));
      final writer = remoteFile.write(stream, onProgress: (sent) {
        onProgress?.call(sent, fileSize);
      });
      await writer.done;
      await remoteFile.close();

      if (server != null) {
        activityService?.logFileAction(server, remotePath, 'upload');
      }

      await loadDirectory(sessionId, state.currentPath);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to upload file to $remoteDirectory: $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Downloads a remote file to localDestinationPath via SFTP.
  Future<Result<void>> downloadFile(
    String sessionId,
    FileEntryEntity item,
    String localDestinationPath, {
    ServerEntity? server,
    void Function(int received, int total)? onProgress,
  }) async {
    if (item.isDirectory) {
      return const Failure('Cannot download a directory directly.');
    }
    if (item.size > maxTransferBytes) {
      return const Failure('File size exceeds the 100 MB download limit.');
    }

    try {
      final sftp = await sshManager.getSftp(sessionId);
      final remoteFile = await sftp.open(item.path);
      final stat = await remoteFile.stat();
      final actualSize = stat.size ?? item.size;
      if (actualSize > maxTransferBytes) {
        await remoteFile.close();
        return const Failure('File size exceeds the 100 MB download limit.');
      }

      final localFile = File(localDestinationPath);
      final sink = localFile.openWrite();

      try {
        await remoteFile.downloadTo(
          sink,
          closeDestination: true,
          onProgress: (bytesRead) {
            if (bytesRead > maxTransferBytes) {
              throw Exception('File download exceeded maximum transfer limit of 100 MB.');
            }
            onProgress?.call(bytesRead, actualSize);
          },
        );
      } catch (streamErr) {
        await remoteFile.close();
        if (await localFile.exists()) {
          try {
            await localFile.delete();
          } catch (delErr) {
            AppLogger.instance.warn('FileManagerController', 'Could not delete partial download: $delErr');
          }
        }
        rethrow;
      }
      await remoteFile.close();

      if (server != null) {
        activityService?.logFileAction(server, item.path, 'download');
      }

      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to download file ${item.name}: $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Renames an existing remote file or directory via SFTP.
  Future<Result<void>> renameEntry(
    String sessionId,
    String oldPath,
    String newPath, {
    ServerEntity? server,
  }) async {
    final trimmedNew = newPath.trim();
    if (trimmedNew.isEmpty || trimmedNew.contains('\x00')) {
      return const Failure('Invalid target path.');
    }
    try {
      final sftp = await sshManager.getSftp(sessionId);
      await sftp.rename(oldPath, trimmedNew);

      if (server != null) {
        activityService?.logFileAction(server, '$oldPath -> $trimmedNew', 'rename');
      }

      await loadDirectory(sessionId, state.currentPath, isSilent: true);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to rename $oldPath to $trimmedNew: $e';
      AppLogger.instance.error('FileManagerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }
}

/// Auto-disposed Riverpod provider for FileManager.
final fileManagerControllerProvider =
    StateNotifierProvider.autoDispose<FileManagerController, FileManagerState>((ref) {
  return FileManagerController(
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});
