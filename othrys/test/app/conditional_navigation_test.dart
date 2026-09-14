import 'dart:async';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/app/app.dart';
import 'package:vpsmanager/core/enums/connection_state.dart' as app_conn;
import 'package:vpsmanager/core/l10n/l10n.dart';
import 'package:vpsmanager/features/servers/server_controller.dart';

class _FakeSSHSocket implements SSHSocket {
  final _controller = StreamController<Uint8List>.broadcast();
  final _sinkController = StreamController<List<int>>.broadcast();

  @override
  Stream<Uint8List> get stream => _controller.stream;
  @override
  StreamSink<List<int>> get sink => _sinkController.sink;
  @override
  Future<void> get done => _controller.done;
  @override
  Future<void> close() async {
    await _controller.close();
    await _sinkController.close();
  }
  @override
  void destroy() {
    _controller.close();
    _sinkController.close();
  }
  @override
  Future<void> flush() async {}
}

class _TestServerController extends StateNotifier<ServerState> implements ServerController {
  _TestServerController(super.state);

  void simulateConnection(ActiveSSHSession? session) {
    state = state.copyWith(
      activeSession: session,
      clearActiveSession: session == null,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Navigation pane shows only Server when disconnected, and reveals all tabs when connected',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final controller = _TestServerController(const ServerState());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverControllerProvider.overrideWith((ref) => controller),
        ],
        child: const FluentApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainShellView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. When disconnected: Only Servers (and Settings in footer) exist
    expect(find.byIcon(FluentIcons.server), findsWidgets);
    expect(find.byIcon(FluentIcons.settings), findsOneWidget);
    // Operational tabs must NOT be present
    expect(find.byIcon(FluentIcons.command_prompt), findsNothing); // Terminal
    expect(find.byIcon(FluentIcons.folder_open), findsNothing); // Files
    expect(find.byIcon(FluentIcons.branch_fork), findsNothing); // Git
    expect(find.byIcon(FluentIcons.line_chart), findsNothing); // Monitoring
    expect(find.byIcon(FluentIcons.package), findsNothing); // Docker
    expect(find.byIcon(FluentIcons.developer_tools), findsNothing); // Services
    expect(find.byIcon(FluentIcons.database), findsNothing); // Databases
    expect(find.byIcon(FluentIcons.globe), findsNothing); // Web Sites & SSL
    expect(find.byIcon(FluentIcons.shield), findsNothing); // Security & Admin
    expect(find.byIcon(FluentIcons.plug_connected), findsNothing); // Tunnels
    expect(find.byIcon(FluentIcons.history), findsNothing); // Activity

    // 2. Connect to a server: all operational tabs become visible
    final dummyServer = ServerEntity(
      id: 'srv-1',
      name: 'Production VPS',
      host: '1.2.3.4',
      port: 22,
      username: 'root',
    );
    final dummyClient = SSHClient(_FakeSSHSocket(), username: 'root');
    final activeSession = ActiveSSHSession(
      sessionId: 'sess-1',
      server: dummyServer,
      client: dummyClient,
      status: app_conn.ConnectionState.connected,
    );

    controller.simulateConnection(activeSession);
    await tester.pumpAndSettle();

    // All tabs must now be visible in the navigation pane
    expect(find.byIcon(FluentIcons.command_prompt), findsOneWidget);
    expect(find.byIcon(FluentIcons.folder_open), findsOneWidget);
    expect(find.byIcon(FluentIcons.branch_fork), findsOneWidget);
    expect(find.byIcon(FluentIcons.line_chart), findsOneWidget);
    expect(find.byIcon(FluentIcons.package), findsOneWidget);
    expect(find.byIcon(FluentIcons.developer_tools), findsOneWidget);
    expect(find.byIcon(FluentIcons.database), findsOneWidget);
    expect(find.byIcon(FluentIcons.globe), findsOneWidget);
    expect(find.byIcon(FluentIcons.shield), findsOneWidget);
    expect(find.byIcon(FluentIcons.plug_connected), findsOneWidget);
    expect(find.byIcon(FluentIcons.history), findsOneWidget);

    // 3. Disconnect from server: navigation collapses back to Server only
    controller.simulateConnection(null);
    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.command_prompt), findsNothing);
    expect(find.byIcon(FluentIcons.folder_open), findsNothing);
    expect(find.byIcon(FluentIcons.branch_fork), findsNothing);
    expect(find.byIcon(FluentIcons.line_chart), findsNothing);
    expect(find.byIcon(FluentIcons.package), findsNothing);
    expect(find.byIcon(FluentIcons.developer_tools), findsNothing);
    expect(find.byIcon(FluentIcons.database), findsNothing);
    expect(find.byIcon(FluentIcons.globe), findsNothing);
    expect(find.byIcon(FluentIcons.shield), findsNothing);
    expect(find.byIcon(FluentIcons.plug_connected), findsNothing);
    expect(find.byIcon(FluentIcons.history), findsNothing);
    expect(find.byIcon(FluentIcons.server), findsWidgets);
  });
}
