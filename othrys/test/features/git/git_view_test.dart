import 'package:dartssh2/dartssh2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/l10n/l10n.dart';
import 'package:othrys/features/git/git_controller.dart';
import 'package:othrys/features/git/git_view.dart';
import 'package:othrys/features/servers/server_controller.dart';

class _FakeSSHClient extends Fake implements SSHClient {
  @override
  void close() {}
}

class _FakeGitController extends StateNotifier<GitState> implements GitController {
  _FakeGitController(super.state);

  @override
  Future<void> loadTrackedRepositories(String sessionId, String serverId) async {}

  @override
  Future<void> checkGitInstalled(String sessionId) async {}

  @override
  Future<void> refreshRepository(String sessionId, String repoPath) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeServerController extends StateNotifier<ServerState> implements ServerController {
  _FakeServerController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('GitView renders cleanly with active session and tracked repository', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final dummyServer = ServerEntity(
      id: 'srv-1',
      name: 'Production VPS',
      host: '1.2.3.4',
      port: 22,
      username: 'root',
    );

    final fakeGitState = GitState(
      isGitInstalled: true,
      trackedRepoPaths: const ['/var/www/my-app'],
      selectedRepoPath: '/var/www/my-app',
      selectedRepo: const GitRepositoryInfo(
        path: '/var/www/my-app',
        name: 'my-app',
        currentBranch: 'main',
        isClean: true,
      ),
    );

    final dummyClient = _FakeSSHClient();

    final fakeServerState = ServerState(
      activeSession: ActiveSSHSession(
        sessionId: 'sess-1',
        server: dummyServer,
        client: dummyClient,
      ),
    );

    final gitController = _FakeGitController(fakeGitState);
    final serverController = _FakeServerController(fakeServerState);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gitControllerProvider.overrideWith((ref) => gitController),
          serverControllerProvider.overrideWith((ref) => serverController),
        ],
        child: const FluentApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fr'),
          home: GitView(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify header title and buttons render with no ParentDataWidget or RenderFlex overflow errors
    expect(find.text('Dépôts Git'), findsOneWidget);
    expect(find.byIcon(FluentIcons.search), findsOneWidget);
    expect(find.byIcon(FluentIcons.folder_open), findsOneWidget);
    expect(find.byIcon(FluentIcons.refresh), findsWidgets);
    expect(find.text('Cloner un dépôt'), findsOneWidget);

    // Verify repo card
    expect(find.text('/var/www/my-app'), findsOneWidget);
    expect(find.text('main'), findsOneWidget);
    expect(find.text('À jour avec origin'), findsOneWidget);
  });
}
