import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/activity_log_entity.dart';
import '../../core/models/git_entities.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/security/command_sanitizer.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/git_entities.dart';

/// State representation for remote Git operations.
class GitState {
  final bool isGitInstalled;
  final String? gitVersion;
  final List<String> trackedRepoPaths;
  final String? selectedRepoPath;
  final GitRepositoryInfo? selectedRepo;
  final List<GitCommit> history;
  final GitDeployKey deployKey;
  final GitConfig gitConfig;
  final bool isLoading;
  final String? actionFeedback;
  final String? errorMessage;

  const GitState({
    this.isGitInstalled = false,
    this.gitVersion,
    this.trackedRepoPaths = const [],
    this.selectedRepoPath,
    this.selectedRepo,
    this.history = const [],
    this.deployKey = const GitDeployKey(),
    this.gitConfig = const GitConfig(),
    this.isLoading = false,
    this.actionFeedback,
    this.errorMessage,
  });

  GitState copyWith({
    bool? isGitInstalled,
    String? gitVersion,
    List<String>? trackedRepoPaths,
    String? selectedRepoPath,
    GitRepositoryInfo? selectedRepo,
    bool clearSelectedRepo = false,
    List<GitCommit>? history,
    GitDeployKey? deployKey,
    GitConfig? gitConfig,
    bool? isLoading,
    String? actionFeedback,
    bool clearActionFeedback = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GitState(
      isGitInstalled: isGitInstalled ?? this.isGitInstalled,
      gitVersion: gitVersion ?? this.gitVersion,
      trackedRepoPaths: trackedRepoPaths ?? this.trackedRepoPaths,
      selectedRepoPath: selectedRepoPath ?? this.selectedRepoPath,
      selectedRepo: clearSelectedRepo ? null : (selectedRepo ?? this.selectedRepo),
      history: history ?? this.history,
      deployKey: deployKey ?? this.deployKey,
      gitConfig: gitConfig ?? this.gitConfig,
      isLoading: isLoading ?? this.isLoading,
      actionFeedback: clearActionFeedback ? null : (actionFeedback ?? this.actionFeedback),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Controller orchestrating Git installation, repository discovery, branch switching,
/// status tracking, pulls, and deploy keys.
class GitController extends StateNotifier<GitState> {
  final SSHSessionManager _ssh;
  final ActivityService? _activity;
  final SharedPreferences? _prefs;

  GitController(this._ssh, this._activity, this._prefs) : super(const GitState());

  // ================= Parsing Helpers (Static for Unit Testing) =================

  /// Parses `git status --porcelain` into a list of GitFileStatus entries.
  static List<GitFileStatus> parsePorcelainStatus(String output) {
    final results = <GitFileStatus>[];
    final lines = output.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      if (line.length < 3) continue;
      final status = line.substring(0, 2);
      final path = line.substring(3).trim();
      if (path.isEmpty) continue;
      results.add(GitFileStatus(path: path, type: GitFileStatus.parseType(status), statusCode: status.trim()));
    }
    return results;
  }

  /// Parses `git rev-list --left-right --count HEAD...@{u}` into ahead/behind counts.
  static ({int ahead, int behind}) parseAheadBehind(String output) {
    final parts = output.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (ahead: int.tryParse(parts[0]) ?? 0, behind: int.tryParse(parts[1]) ?? 0);
    }
    return (ahead: 0, behind: 0);
  }

  /// Parses `git branch -a` into local and remote branches.
  static ({List<String> local, List<String> remote}) parseBranches(String output) {
    final localBranches = <String>[];
    final remoteBranches = <String>[];
    for (final line in output.split(RegExp(r'\r?\n'))) {
      final clean = line.replaceAll('*', '').trim();
      if (clean.isEmpty || clean.contains('->')) continue;
      if (clean.startsWith('remotes/')) {
        final rName = clean.replaceFirst('remotes/', '');
        if (!remoteBranches.contains(rName)) remoteBranches.add(rName);
      } else if (!localBranches.contains(clean)) {
        localBranches.add(clean);
      }
    }
    return (local: localBranches, remote: remoteBranches);
  }

  /// Parses `git log -n ... --pretty=format:"%h%x09%an%x09%ar%x09%s"` into GitCommit list.
  static List<GitCommit> parseCommits(String output) {
    final commits = <GitCommit>[];
    final lines = output.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final parts = line.split('\t');
      if (parts.length >= 4) {
        commits.add(GitCommit(
          hash: parts[0].trim(),
          author: parts[1].trim(),
          date: parts[2].trim(),
          message: parts.sublist(3).join('\t').trim(),
        ));
      }
    }
    return commits;
  }

  /// Parses discovery paths from `find ... -name .git -type d`.
  static List<String> parseDiscoveredRepos(String output) {
    final paths = <String>[];
    final lines = output.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      // Strip trailing /.git or /.git/
      final clean = trimmed.replaceAll(RegExp(r'[/\\]\.git[/\\?]?$'), '');
      if (clean.isNotEmpty && !paths.contains(clean)) {
        paths.add(clean);
      }
    }
    return paths;
  }

  // ================= Remote Operations =================

  void _safeSetState(GitState Function(GitState s) updater) {
    if (mounted) state = updater(state);
  }

  /// Checks if Git is installed on the remote machine.
  Future<void> checkGitInstalled(String sessionId) async {
    try {
      final res = await _ssh.executeCommand(sessionId, 'git --version 2>&1');
      if (res.toLowerCase().contains('git version')) {
        _safeSetState((s) => s.copyWith(isGitInstalled: true, gitVersion: res.trim()));
      } else {
        _safeSetState((s) => s.copyWith(isGitInstalled: false, gitVersion: null));
      }
    } catch (_) {
      _safeSetState((s) => s.copyWith(isGitInstalled: false, gitVersion: null));
    }
  }

  /// Installs Git on the remote server via apt-get.
  Future<Result<void>> installGit(String sessionId, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      await _ssh.executeCommand(
        sessionId,
        'sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git',
      );
      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Installed Git package',
          category: ActivityCategory.system,
        );
      }
      await checkGitInstalled(sessionId);
      _safeSetState((s) => s.copyWith(isLoading: false));
      return const Success(null);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Install Git failed: $e'));
      return Failure('installGit error: $e', e, st);
    }
  }

  /// Loads tracked repos from local storage, or auto-scans if empty.
  Future<void> loadTrackedRepositories(String sessionId, String serverId) async {
    _safeSetState((s) => s.copyWith(isLoading: true));
    try {
      await checkGitInstalled(sessionId);
      await loadDeployKey(sessionId);
      await loadGitConfig(sessionId);

      final key = 'git_tracked_$serverId';
      List<String> tracked = _prefs?.getStringList(key) ?? [];

      if (tracked.isEmpty) {
        tracked = await _scanCommonPaths(sessionId);
        if (tracked.isNotEmpty && _prefs != null) {
          await _prefs.setStringList(key, tracked);
        }
      }

      _safeSetState((s) => s.copyWith(
        trackedRepoPaths: tracked,
        selectedRepoPath: tracked.isNotEmpty ? (s.selectedRepoPath ?? tracked.first) : null,
        isLoading: false,
      ));

      if (state.selectedRepoPath != null) {
        await refreshRepository(sessionId, state.selectedRepoPath!);
      }
    } catch (e, st) {
      AppLogger.instance.error('GitController', 'loadTrackedRepositories error: $e', e, st);
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Failed to load repositories: $e'));
    }
  }

  /// Scans common filesystem paths for `.git` directories.
  Future<List<String>> _scanCommonPaths(String sessionId) async {
    try {
      final res = await _ssh.executeCommand(
        sessionId,
        'find /var/www /home /opt ~ -maxdepth 3 -name .git -type d 2>/dev/null || true',
      );
      return parseDiscoveredRepos(res);
    } catch (_) {
      return [];
    }
  }

  /// Scans the server and adds newly discovered repos.
  Future<int> scanServer(String sessionId, String serverId) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearActionFeedback: true));
    try {
      final found = await _scanCommonPaths(sessionId);
      final current = Set<String>.from(state.trackedRepoPaths)..addAll(found);
      final updatedList = current.toList();

      final key = 'git_tracked_$serverId';
      if (_prefs != null) {
        await _prefs.setStringList(key, updatedList);
      }

      _safeSetState((s) => s.copyWith(
        trackedRepoPaths: updatedList,
        selectedRepoPath: s.selectedRepoPath ?? (updatedList.isNotEmpty ? updatedList.first : null),
        isLoading: false,
      ));

      if (state.selectedRepoPath != null) {
        await refreshRepository(sessionId, state.selectedRepoPath!);
      }
      return found.length;
    } catch (e) {
      _safeSetState((s) => s.copyWith(isLoading: false));
      return 0;
    }
  }

  /// Adds an existing directory as a tracked Git repository.
  Future<Result<void>> addTrackedRepository(String sessionId, String serverId, String repoPath) async {
    try {
      final trimmed = repoPath.trim();
      final escaped = CommandSanitizer.escapeArg(trimmed);
      final isRepo = await _ssh.executeCommand(sessionId, 'cd $escaped && git rev-parse --is-inside-work-tree 2>&1');
      if (!isRepo.trim().contains('true')) {
        return const Failure('Specified directory is not a valid Git repository');
      }

      final updated = List<String>.from(state.trackedRepoPaths);
      if (!updated.contains(trimmed)) {
        updated.add(trimmed);
        final key = 'git_tracked_$serverId';
        if (_prefs != null) {
          await _prefs.setStringList(key, updated);
        }
      }

      _safeSetState((s) => s.copyWith(trackedRepoPaths: updated, selectedRepoPath: trimmed));
      await refreshRepository(sessionId, trimmed);
      return const Success(null);
    } catch (e, st) {
      return Failure('addTrackedRepository error: $e', e, st);
    }
  }

  /// Removes a repository from the tracked list (does NOT delete remote files).
  Future<void> removeTrackedRepository(String serverId, String repoPath) async {
    final updated = List<String>.from(state.trackedRepoPaths)..remove(repoPath);
    final key = 'git_tracked_$serverId';
    if (_prefs != null) {
      await _prefs.setStringList(key, updated);
    }

    final newSelected = updated.isNotEmpty ? updated.first : null;
    _safeSetState((s) => s.copyWith(
      trackedRepoPaths: updated,
      selectedRepoPath: newSelected,
      clearSelectedRepo: newSelected == null,
    ));
  }

  /// Selects and refreshes an active repository.
  Future<void> selectRepository(String sessionId, String repoPath) async {
    _safeSetState((s) => s.copyWith(selectedRepoPath: repoPath));
    await refreshRepository(sessionId, repoPath);
  }

  /// Refreshes all metadata, status, commits, and branches of a repository.
  Future<void> refreshRepository(String sessionId, String repoPath) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final escaped = CommandSanitizer.escapeArg(repoPath);
      final repoName = repoPath.split('/').where((s) => s.isNotEmpty).lastOrNull ?? repoPath;

      // 1. Branch and remote URL
      final meta = await _ssh.executeCommand(
        sessionId,
        'cd $escaped && (git branch --show-current || git rev-parse --short HEAD) && (git config --get remote.origin.url || true)',
      );
      final metaLines = meta.split(RegExp(r'\r?\n')).map((l) => l.trim()).toList();
      final currentBranch = metaLines.isNotEmpty ? metaLines[0] : 'HEAD';
      final remoteUrl = (metaLines.length > 1 && metaLines[1].isNotEmpty) ? metaLines[1] : null;

      // 2. Status porcelain
      final statusOut = await _ssh.executeCommand(sessionId, 'cd $escaped && git status --porcelain');
      final changedFiles = parsePorcelainStatus(statusOut);
      final isClean = changedFiles.isEmpty;

      // 3. Ahead / Behind upstream
      final syncOut = await _ssh.executeCommand(
        sessionId,
        'cd $escaped && (git rev-list --left-right --count HEAD...@{u} 2>/dev/null || echo "0 0")',
      );
      final syncCounts = parseAheadBehind(syncOut);

      // 4. Branches
      final branchesOut = await _ssh.executeCommand(sessionId, 'cd $escaped && git branch -a');
      final branchInfo = parseBranches(branchesOut);

      // 5. Commits
      final logOut = await _ssh.executeCommand(
        sessionId,
        'cd $escaped && (git log -n 30 --pretty=format:"%h%x09%an%x09%ar%x09%s" 2>/dev/null || true)',
      );
      final commits = parseCommits(logOut);
      final lastCommit = commits.isNotEmpty ? commits.first : null;

      final info = GitRepositoryInfo(
        path: repoPath,
        name: repoName,
        remoteUrl: remoteUrl,
        currentBranch: currentBranch,
        isClean: isClean,
        aheadCount: syncCounts.ahead,
        behindCount: syncCounts.behind,
        lastCommit: lastCommit,
        changedFiles: changedFiles,
        localBranches: branchInfo.local,
        remoteBranches: branchInfo.remote,
      );

      _safeSetState((s) => s.copyWith(
        selectedRepo: info,
        history: commits,
        isLoading: false,
      ));
    } catch (e, st) {
      AppLogger.instance.error('GitController', 'refreshRepository error: $e', e, st);
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Failed to inspect repo: $e'));
    }
  }

  /// Performs `git pull` on the selected repository.
  Future<Result<String>> pull(String sessionId, String repoPath, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final escaped = CommandSanitizer.escapeArg(repoPath);
      final out = await _ssh.executeCommand(sessionId, 'cd $escaped && git pull');

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Git Pull executed for $repoPath',
          category: ActivityCategory.system,
        );
      }

      await refreshRepository(sessionId, repoPath);
      return Success(out);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Git pull error: $e'));
      return Failure('Git pull error: $e', e, st);
    }
  }

  /// Performs `git fetch --prune` on the selected repository.
  Future<Result<String>> fetch(String sessionId, String repoPath, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final escaped = CommandSanitizer.escapeArg(repoPath);
      final out = await _ssh.executeCommand(sessionId, 'cd $escaped && git fetch --prune');
      await refreshRepository(sessionId, repoPath);
      return Success(out);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Git fetch error: $e'));
      return Failure('Git fetch error: $e', e, st);
    }
  }

  /// Switches/checkouts to another local or remote branch.
  Future<Result<void>> checkoutBranch(String sessionId, String repoPath, String branch, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final safeRepo = CommandSanitizer.escapeArg(repoPath);
      final safeBranch = branch.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._/-]'), '');
      await _ssh.executeCommand(sessionId, 'cd $safeRepo && git checkout \'$safeBranch\'');

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Git Checkout to branch $safeBranch',
          category: ActivityCategory.system,
        );
      }

      await refreshRepository(sessionId, repoPath);
      return const Success(null);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Checkout branch error: $e'));
      return Failure('Checkout branch error: $e', e, st);
    }
  }

  /// Creates and switches to a new branch.
  Future<Result<void>> createBranch(String sessionId, String repoPath, String newBranch, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final safeRepo = CommandSanitizer.escapeArg(repoPath);
      final safeBranch = newBranch.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._/-]'), '');
      await _ssh.executeCommand(sessionId, 'cd $safeRepo && git checkout -b \'$safeBranch\'');

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Created and switched to Git branch $safeBranch',
          category: ActivityCategory.system,
        );
      }

      await refreshRepository(sessionId, repoPath);
      return const Success(null);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Create branch error: $e'));
      return Failure('Create branch error: $e', e, st);
    }
  }

  /// Discards all local changes and untracked files (`git reset --hard HEAD && git clean -fd`).
  Future<Result<void>> discardChanges(String sessionId, String repoPath, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final safeRepo = CommandSanitizer.escapeArg(repoPath);
      await _ssh.executeCommand(sessionId, 'cd $safeRepo && git reset --hard HEAD && git clean -fd');

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Discarded local Git changes in $repoPath',
          category: ActivityCategory.system,
        );
      }

      await refreshRepository(sessionId, repoPath);
      return const Success(null);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Discard changes error: $e'));
      return Failure('Discard changes error: $e', e, st);
    }
  }

  /// Stashes uncommitted changes.
  Future<Result<void>> stashChanges(String sessionId, String repoPath) async {
    try {
      final safeRepo = CommandSanitizer.escapeArg(repoPath);
      await _ssh.executeCommand(sessionId, 'cd $safeRepo && git stash');
      await refreshRepository(sessionId, repoPath);
      return const Success(null);
    } catch (e, st) {
      return Failure('Stash changes error: $e', e, st);
    }
  }

  /// Restores stashed changes (`git stash pop`).
  Future<Result<void>> popStash(String sessionId, String repoPath) async {
    try {
      final safeRepo = CommandSanitizer.escapeArg(repoPath);
      await _ssh.executeCommand(sessionId, 'cd $safeRepo && git stash pop');
      await refreshRepository(sessionId, repoPath);
      return const Success(null);
    } catch (e, st) {
      return Failure('Pop stash error: $e', e, st);
    }
  }

  /// Stages, commits, and optionally pushes changes to origin.
  Future<Result<void>> commitAndPush(
    String sessionId,
    String repoPath,
    String message,
    bool shouldPush, {
    ServerEntity? server,
  }) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final safeRepo = CommandSanitizer.escapeArg(repoPath);
      final safeMsg = CommandSanitizer.escapeArg(message.trim());

      String cmd = 'cd $safeRepo && git add -A && git commit -m $safeMsg';
      if (shouldPush) {
        cmd += ' && git push';
      }

      await _ssh.executeCommand(sessionId, cmd);

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Git commit ($message)${shouldPush ? ' and pushed' : ''}',
          category: ActivityCategory.system,
        );
      }

      await refreshRepository(sessionId, repoPath);
      return const Success(null);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Commit & Push error: $e'));
      return Failure('Commit & Push error: $e', e, st);
    }
  }

  /// Clones a new Git repository onto the server.
  Future<Result<void>> cloneRepository(
    String sessionId,
    String serverId, {
    required String url,
    required String destPath,
    String? branch,
    bool shallow = false,
    bool submodules = false,
    ServerEntity? server,
  }) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      final cleanUrl = url.trim();
      final cleanDest = destPath.trim();
      final safeDest = CommandSanitizer.escapeArg(cleanDest);
      final safeUrl = CommandSanitizer.escapeArg(cleanUrl);

      final flags = <String>[];
      if (shallow) flags.add('--depth 1');
      if (submodules) flags.add('--recurse-submodules');
      if (branch != null && branch.trim().isNotEmpty) {
        final safeBranch = branch.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._/-]'), '');
        flags.add('-b \'$safeBranch\'');
      }

      final flagStr = flags.isEmpty ? '' : '${flags.join(' ')} ';
      final cmd = 'git clone $flagStr$safeUrl $safeDest';

      await _ssh.executeCommand(sessionId, cmd);

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Cloned Git repository $cleanUrl to $cleanDest',
          category: ActivityCategory.system,
        );
      }

      await addTrackedRepository(sessionId, serverId, cleanDest);
      return const Success(null);
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Clone error: $e'));
      return Failure('Clone error: $e', e, st);
    }
  }

  /// Loads the server's SSH public deploy key (`~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub`).
  Future<void> loadDeployKey(String sessionId) async {
    try {
      final keyOut = await _ssh.executeCommand(
        sessionId,
        'cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub 2>/dev/null || true',
      );
      final trimmed = keyOut.trim();
      if (trimmed.startsWith('ssh-') || trimmed.startsWith('ecdsa-')) {
        final type = trimmed.split(' ').firstOrNull ?? 'ed25519';
        _safeSetState((s) => s.copyWith(deployKey: GitDeployKey(publicKey: trimmed, keyType: type, exists: true)));
      } else {
        _safeSetState((s) => s.copyWith(deployKey: const GitDeployKey(publicKey: null, exists: false)));
      }
    } catch (_) {
      _safeSetState((s) => s.copyWith(deployKey: const GitDeployKey(publicKey: null, exists: false)));
    }
  }

  /// Generates a new ED25519 SSH deploy key on the server.
  Future<Result<String>> generateDeployKey(String sessionId, {ServerEntity? server}) async {
    _safeSetState((s) => s.copyWith(isLoading: true, clearError: true));
    try {
      await _ssh.executeCommand(
        sessionId,
        'mkdir -p ~/.ssh && chmod 700 ~/.ssh && ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519',
      );

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Generated new ED25519 SSH deploy key',
          category: ActivityCategory.system,
        );
      }

      await loadDeployKey(sessionId);
      _safeSetState((s) => s.copyWith(isLoading: false));
      return Success(state.deployKey.publicKey ?? '');
    } catch (e, st) {
      _safeSetState((s) => s.copyWith(isLoading: false, errorMessage: 'Generate deploy key error: $e'));
      return Failure('Generate deploy key error: $e', e, st);
    }
  }

  /// Loads global user name and email from `git config`.
  Future<void> loadGitConfig(String sessionId) async {
    try {
      final name = await _ssh.executeCommand(sessionId, 'git config --global user.name 2>/dev/null || true');
      final email = await _ssh.executeCommand(sessionId, 'git config --global user.email 2>/dev/null || true');
      _safeSetState((s) => s.copyWith(
        gitConfig: GitConfig(
          userName: name.trim().isEmpty ? null : name.trim(),
          userEmail: email.trim().isEmpty ? null : email.trim(),
        ),
      ));
    } catch (_) {}
  }

  /// Updates global git identity config.
  Future<Result<void>> saveGitConfig(String sessionId, String name, String email) async {
    try {
      final safeName = CommandSanitizer.escapeArg(name.trim());
      final safeEmail = CommandSanitizer.escapeArg(email.trim());
      await _ssh.executeCommand(
        sessionId,
        'git config --global user.name $safeName && git config --global user.email $safeEmail',
      );
      await loadGitConfig(sessionId);
      return const Success(null);
    } catch (e, st) {
      return Failure('Save git config error: $e', e, st);
    }
  }
}

/// Provider exposing GitController.
final gitControllerProvider = StateNotifierProvider<GitController, GitState>((ref) {
  return GitController(
    ref.watch(sshSessionManagerProvider),
    ref.watch(activityServiceProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
