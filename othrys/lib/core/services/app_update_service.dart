import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// Metadata for an available application update released on GitHub.
class UpdateReleaseInfo {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final int sizeBytes;
  final DateTime? publishedAt;

  const UpdateReleaseInfo({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    this.sizeBytes = 0,
    this.publishedAt,
  });
}

/// State of the in-app updater.
class AppUpdateState {
  final bool isChecking;
  final bool isDownloading;
  final double downloadProgress;
  final UpdateReleaseInfo? availableUpdate;
  final String? errorMessage;
  final bool isReadyToInstall;
  final String? downloadedInstallerPath;
  final bool userDismissed;

  const AppUpdateState({
    this.isChecking = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.availableUpdate,
    this.errorMessage,
    this.isReadyToInstall = false,
    this.downloadedInstallerPath,
    this.userDismissed = false,
  });

  AppUpdateState copyWith({
    bool? isChecking,
    bool? isDownloading,
    double? downloadProgress,
    UpdateReleaseInfo? availableUpdate,
    String? errorMessage,
    bool? isReadyToInstall,
    String? downloadedInstallerPath,
    bool? userDismissed,
  }) => AppUpdateState(
    isChecking: isChecking ?? this.isChecking,
    isDownloading: isDownloading ?? this.isDownloading,
    downloadProgress: downloadProgress ?? this.downloadProgress,
    availableUpdate: availableUpdate ?? this.availableUpdate,
    errorMessage: errorMessage,
    isReadyToInstall: isReadyToInstall ?? this.isReadyToInstall,
    downloadedInstallerPath: downloadedInstallerPath ?? this.downloadedInstallerPath,
    userDismissed: userDismissed ?? this.userDismissed,
  );
}

/// Service orchestrating GitHub release polling, binary downloading, and seamless in-app updates.
class AppUpdateService extends StateNotifier<AppUpdateState> {
  static const String currentVersion = '0.1.0';
  static const String githubRepo = 'Dali999999999/Othrys';

  AppUpdateService() : super(const AppUpdateState());

  /// Checks GitHub Releases API for newer application builds.
  Future<UpdateReleaseInfo?> checkForUpdate({bool manualTrigger = false}) async {
    if (state.isChecking || state.isDownloading) return state.availableUpdate;

    state = state.copyWith(isChecking: true, errorMessage: null);

    try {
      final client = HttpClient();
      final uri = Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest');
      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'Othrys-Desktop-App');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close().timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        client.close();
        state = state.copyWith(
          isChecking: false,
          errorMessage: manualTrigger ? 'Vérification impossible (Code ${response.statusCode})' : null,
        );
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      client.close();

      final json = jsonDecode(body) as Map<String, dynamic>;
      final rawTag = (json['tag_name'] as String? ?? '').trim();
      final remoteVersion = rawTag.startsWith('v') ? rawTag.substring(1) : rawTag;
      final releaseNotes = json['body'] as String? ?? '';
      final publishedStr = json['published_at'] as String?;
      final publishedAt = publishedStr != null ? DateTime.tryParse(publishedStr) : null;

      if (isNewerVersion(remoteVersion, currentVersion)) {
        final assets = json['assets'] as List<dynamic>? ?? [];
        String? downloadUrl;
        int sizeBytes = 0;

        for (final asset in assets) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.exe') && (name.contains('setup') || name.contains('othrys'))) {
            downloadUrl = asset['browser_download_url'] as String?;
            sizeBytes = asset['size'] as int? ?? 0;
            break;
          }
        }

        // Fallback to first .exe if specific setup name not matched
        if (downloadUrl == null) {
          for (final asset in assets) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            if (name.endsWith('.exe')) {
              downloadUrl = asset['browser_download_url'] as String?;
              sizeBytes = asset['size'] as int? ?? 0;
              break;
            }
          }
        }

        if (downloadUrl != null) {
          final releaseInfo = UpdateReleaseInfo(
            version: remoteVersion,
            releaseNotes: releaseNotes,
            downloadUrl: downloadUrl,
            sizeBytes: sizeBytes,
            publishedAt: publishedAt,
          );

          state = state.copyWith(
            isChecking: false,
            availableUpdate: releaseInfo,
            userDismissed: false,
          );
          return releaseInfo;
        }
      }

      state = state.copyWith(isChecking: false, availableUpdate: null);
      return null;
    } catch (e, st) {
      AppLogger.instance.error('AppUpdateService', 'Error checking for updates: $e', e, st);
      state = state.copyWith(
        isChecking: false,
        errorMessage: manualTrigger ? 'Erreur de connexion lors de la vérification.' : null,
      );
      return null;
    }
  }

  /// Downloads the installer executable with progress reporting.
  Future<bool> downloadUpdate() async {
    final update = state.availableUpdate;
    if (update == null || state.isDownloading) return false;

    state = state.copyWith(isDownloading: true, downloadProgress: 0.0, errorMessage: null);

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(update.downloadUrl));
      request.headers.set('User-Agent', 'Othrys-Desktop-App');
      final response = await request.close();

      if (response.statusCode != 200) {
        client.close();
        state = state.copyWith(isDownloading: false, errorMessage: 'Échec du téléchargement (HTTP ${response.statusCode})');
        return false;
      }

      final contentLength = response.contentLength;
      final tempDir = Directory.systemTemp;
      final installerFile = File('${tempDir.path}\\Othrys-Setup-${update.version}.exe');

      final sink = installerFile.openWrite();
      int receivedBytes = 0;

      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          state = state.copyWith(downloadProgress: receivedBytes / contentLength);
        }
      }

      await sink.flush();
      await sink.close();
      client.close();

      state = state.copyWith(
        isDownloading: false,
        isReadyToInstall: true,
        downloadProgress: 1.0,
        downloadedInstallerPath: installerFile.path,
      );
      return true;
    } catch (e, st) {
      AppLogger.instance.error('AppUpdateService', 'Error downloading update: $e', e, st);
      state = state.copyWith(isDownloading: false, errorMessage: 'Erreur lors du téléchargement de la mise à jour.');
      return false;
    }
  }

  /// Launches the installer silently and shuts down Othrys so the update can proceed.
  Future<void> launchInstallerAndExit() async {
    final path = state.downloadedInstallerPath;
    if (path == null || !File(path).existsSync()) return;

    try {
      // Launch installer silently or with standard wizard
      await Process.start(path, ['/SILENT'], mode: ProcessStartMode.detached);
      exit(0);
    } catch (e, st) {
      AppLogger.instance.error('AppUpdateService', 'Failed to launch installer: $e', e, st);
    }
  }

  /// Dismisses the active update banner for the current session.
  void dismissBanner() {
    state = state.copyWith(userDismissed: true);
  }

  /// Compares two semver strings (e.g., "0.1.1" vs "0.1.0").
  /// Returns true if [remote] is strictly greater than [local].
  static bool isNewerVersion(String remote, String local) {
    try {
      final rParts = remote.split('+').first.split('-').first.split('.').map(int.parse).toList();
      final lParts = local.split('+').first.split('-').first.split('.').map(int.parse).toList();

      while (rParts.length < 3) {
        rParts.add(0);
      }
      while (lParts.length < 3) {
        lParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (rParts[i] > lParts[i]) return true;
        if (rParts[i] < lParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

final appUpdateServiceProvider = StateNotifierProvider<AppUpdateService, AppUpdateState>((ref) {
  return AppUpdateService();
});
