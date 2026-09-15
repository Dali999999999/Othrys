import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/docker_container_entity.dart';
import '../../core/network/is_ssh_session_manager.dart';
import '../../core/security/command_sanitizer.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../core/utils/shell_commands.dart';
import '../servers/server_controller.dart';

export '../../core/models/docker_container_entity.dart';

/// State representation for Docker container list and operations.
class DockerState {
  final List<DockerContainerEntity> containers;
  final bool isDockerInstalled;
  final bool hasDockerCompose;
  final String composeCommand;
  final String? composeOutput;
  final bool isComposeRunning;
  final bool isLoading;
  final String? error;

  const DockerState({
    this.containers = const [],
    this.isDockerInstalled = true,
    this.hasDockerCompose = false,
    this.composeCommand = 'docker compose',
    this.composeOutput,
    this.isComposeRunning = false,
    this.isLoading = false,
    this.error,
  });

  DockerState copyWith({
    List<DockerContainerEntity>? containers,
    bool? isDockerInstalled,
    bool? hasDockerCompose,
    String? composeCommand,
    String? composeOutput,
    bool? isComposeRunning,
    bool? isLoading,
    String? error,
  }) {
    return DockerState(
      containers: containers ?? this.containers,
      isDockerInstalled: isDockerInstalled ?? this.isDockerInstalled,
      hasDockerCompose: hasDockerCompose ?? this.hasDockerCompose,
      composeCommand: composeCommand ?? this.composeCommand,
      composeOutput: composeOutput ?? this.composeOutput,
      isComposeRunning: isComposeRunning ?? this.isComposeRunning,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller managing remote Docker container discovery, compose, and lifecycle commands.
class DockerController extends StateNotifier<DockerState> {
  final ISSHSessionManager sshManager;
  final ActivityService? activityService;

  DockerController({
    required this.sshManager,
    this.activityService,
  }) : super(const DockerState());

  /// Queries all containers on the remote host and detects docker & compose availability.
  Future<Result<List<DockerContainerEntity>>> loadContainers(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check whether docker binary exists on server
      final whichDocker = await sshManager.executeCommand(sessionId, 'which docker || true');
      if (whichDocker.trim().isEmpty || whichDocker.contains('no docker in')) {
        state = state.copyWith(isDockerInstalled: false, isLoading: false, containers: []);
        return const Success([]);
      }

      // Check whether docker compose / docker-compose is available
      bool hasCompose = false;
      String composeCmd = 'docker compose';
      final composeCheck = await sshManager.executeCommand(
        sessionId,
        'docker compose version 2>/dev/null || docker-compose version 2>/dev/null || true',
      );
      if (composeCheck.contains('Docker Compose version') ||
          composeCheck.contains('version v') ||
          composeCheck.contains('version 1') ||
          composeCheck.contains('version 2')) {
        hasCompose = true;
        if (!composeCheck.contains('Docker Compose version') && composeCheck.contains('docker-compose')) {
          composeCmd = 'docker-compose';
        }
      }

      const cmd = 'docker ps -a --format "{{json .}}"';
      final output = await sshManager.executeCommand(sessionId, cmd);

      final List<DockerContainerEntity> list = [];
      for (final line in output.trim().split('\n')) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> data = jsonDecode(line);
          list.add(DockerContainerEntity.fromJson(data));
        } catch (e) {
          AppLogger.instance.warn('DockerController', 'Could not parse container line JSON: $e');
        }
      }

      state = state.copyWith(
        containers: list,
        isDockerInstalled: true,
        hasDockerCompose: hasCompose,
        composeCommand: composeCmd,
        isLoading: false,
      );
      return Success(list);
    } catch (e, st) {
      final msg = 'Docker error: $e';
      AppLogger.instance.error('DockerController', msg, e, st);
      state = state.copyWith(isLoading: false, error: msg);
      return Failure(msg, e, st);
    }
  }

  static const Set<String> _allowedComposeActions = {
    'up',
    'down',
    'restart',
    'logs',
    'ps',
    'stop',
    'start',
    'build',
    'pull',
  };

  /// Executes a docker compose command in the given remote directory safely.
  Future<Result<String>> runComposeAction(
    String sessionId,
    String projectDir,
    String action, {
    ServerEntity? server,
  }) async {
    final effectiveDir = projectDir.trim().isEmpty ? '.' : projectDir.trim();

    // Parse and validate action arguments
    final parts = action.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      return const Failure('Compose action cannot be empty');
    }

    final rootAction = parts.first;
    if (!_allowedComposeActions.contains(rootAction)) {
      return Failure('Disallowed compose action: "$rootAction"');
    }

    for (final token in parts) {
      if (!CommandSanitizer.isValidComposeToken(token)) {
        return Failure('Dangerous token detected in compose argument: "$token"');
      }
    }

    state = state.copyWith(isComposeRunning: true);
    try {
      final cmd = ShellCommands.dockerCompose(
        effectiveDir,
        parts,
        composeCommand: state.composeCommand,
      );
      final output = await sshManager.executeCommand(sessionId, cmd);
      state = state.copyWith(isComposeRunning: false, composeOutput: output);
      if (server != null) {
        activityService?.logDockerAction(server, 'compose:$effectiveDir', action);
      }
      if (action.contains('up') || action.contains('down') || action.contains('restart')) {
        await loadContainers(sessionId);
      }
      return Success(output);
    } catch (e, st) {
      final msg = 'Failed to execute compose $action: $e';
      AppLogger.instance.error('DockerController', msg, e, st);
      state = state.copyWith(isComposeRunning: false, composeOutput: msg);
      return Failure(msg, e, st);
    }
  }

  /// Sends a start signal to the target container.
  Future<Result<void>> startContainer(String sessionId, DockerContainerEntity container, {ServerEntity? server}) async {
    return _executeContainerAction(sessionId, container, 'start', ['start', container.id], server: server);
  }

  /// Sends a graceful stop signal to the target container.
  Future<Result<void>> stopContainer(String sessionId, DockerContainerEntity container, {ServerEntity? server}) async {
    return _executeContainerAction(sessionId, container, 'stop', ['stop', container.id], server: server);
  }

  /// Restarts the target container.
  Future<Result<void>> restartContainer(String sessionId, DockerContainerEntity container, {ServerEntity? server}) async {
    return _executeContainerAction(sessionId, container, 'restart', ['restart', container.id], server: server);
  }

  /// Forcefully removes the target container.
  Future<Result<void>> removeContainer(String sessionId, DockerContainerEntity container, {ServerEntity? server}) async {
    return _executeContainerAction(sessionId, container, 'remove', ['rm', '-f', container.id], server: server);
  }

  /// Retrieves the tail logs of a container.
  Future<Result<String>> getLogs(String sessionId, String containerId, {int tail = 100}) async {
    try {
      final output = await sshManager.executeSafeCommand(
        sessionId,
        'docker',
        ['logs', '--tail', tail.toString(), containerId],
      );
      return Success(output);
    } catch (e, st) {
      AppLogger.instance.error('DockerController', 'Failed to read logs for $containerId: $e', e, st);
      return Failure('Failed to fetch container logs: $e', e, st);
    }
  }

  Future<Result<void>> _executeContainerAction(
    String sessionId,
    DockerContainerEntity container,
    String actionName,
    List<String> args, {
    ServerEntity? server,
  }) async {
    try {
      await sshManager.executeSafeCommand(sessionId, 'docker', args);
      if (server != null) {
        activityService?.logDockerAction(server, container.names, actionName);
      }
      await loadContainers(sessionId);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to $actionName container ${container.names}: $e';
      AppLogger.instance.error('DockerController', msg, e, st);
      return Failure(msg, e, st);
    }
  }
}

/// Riverpod provider for Docker operations.
final dockerControllerProvider =
    StateNotifierProvider.autoDispose<DockerController, DockerState>((ref) {
  return DockerController(
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});

