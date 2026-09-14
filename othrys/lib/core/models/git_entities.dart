import 'package:flutter/foundation.dart';

/// Type of file change reported by git status.
enum GitChangeType {
  modified,
  untracked,
  deleted,
  added,
  renamed,
  copied,
}

/// Represents a changed file in a Git working tree.
@immutable
class GitFileStatus {
  final String path;
  final GitChangeType type;
  final String statusCode;

  const GitFileStatus({
    required this.path,
    required this.type,
    required this.statusCode,
  });

  static GitChangeType parseType(String code) {
    final trimmed = code.trim();
    if (trimmed == '??') return GitChangeType.untracked;
    if (trimmed == 'M' || trimmed.contains('M')) return GitChangeType.modified;
    if (trimmed == 'D' || trimmed.contains('D')) return GitChangeType.deleted;
    if (trimmed == 'A' || trimmed.contains('A')) return GitChangeType.added;
    if (trimmed == 'R' || trimmed.contains('R')) return GitChangeType.renamed;
    if (trimmed == 'C' || trimmed.contains('C')) return GitChangeType.copied;
    return GitChangeType.modified;
  }
}

/// Represents a Git commit entry in history.
@immutable
class GitCommit {
  final String hash;
  final String author;
  final String date;
  final String message;

  const GitCommit({
    required this.hash,
    required this.author,
    required this.date,
    required this.message,
  });
}

/// Represents the SSH deploy key on the remote server.
@immutable
class GitDeployKey {
  final String? publicKey;
  final String keyType;
  final bool exists;

  const GitDeployKey({
    this.publicKey,
    this.keyType = 'ed25519',
    this.exists = false,
  });
}

/// Global or local Git user identity.
@immutable
class GitConfig {
  final String? userName;
  final String? userEmail;

  const GitConfig({
    this.userName,
    this.userEmail,
  });
}

/// Comprehensive information for a tracked Git repository on the remote VPS.
@immutable
class GitRepositoryInfo {
  final String path;
  final String name;
  final String? remoteUrl;
  final String currentBranch;
  final bool isClean;
  final int aheadCount;
  final int behindCount;
  final GitCommit? lastCommit;
  final List<GitFileStatus> changedFiles;
  final List<String> localBranches;
  final List<String> remoteBranches;

  const GitRepositoryInfo({
    required this.path,
    required this.name,
    this.remoteUrl,
    this.currentBranch = 'main',
    this.isClean = true,
    this.aheadCount = 0,
    this.behindCount = 0,
    this.lastCommit,
    this.changedFiles = const [],
    this.localBranches = const [],
    this.remoteBranches = const [],
  });

  GitRepositoryInfo copyWith({
    String? path,
    String? name,
    String? remoteUrl,
    String? currentBranch,
    bool? isClean,
    int? aheadCount,
    int? behindCount,
    GitCommit? lastCommit,
    List<GitFileStatus>? changedFiles,
    List<String>? localBranches,
    List<String>? remoteBranches,
  }) {
    return GitRepositoryInfo(
      path: path ?? this.path,
      name: name ?? this.name,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      currentBranch: currentBranch ?? this.currentBranch,
      isClean: isClean ?? this.isClean,
      aheadCount: aheadCount ?? this.aheadCount,
      behindCount: behindCount ?? this.behindCount,
      lastCommit: lastCommit ?? this.lastCommit,
      changedFiles: changedFiles ?? this.changedFiles,
      localBranches: localBranches ?? this.localBranches,
      remoteBranches: remoteBranches ?? this.remoteBranches,
    );
  }
}
