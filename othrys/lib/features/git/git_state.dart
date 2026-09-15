import '../../core/models/git_entities.dart';

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
