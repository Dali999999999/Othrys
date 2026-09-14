import 'dart:async';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'core/security/encryption_vault.dart';
import 'core/services/settings_service.dart';
import 'core/utils/logger.dart';
import 'app/app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      AppLogger.instance.error('FlutterError', details.exceptionAsString(), details.exception, details.stack);
    };

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(1280, 800),
        minimumSize: Size(960, 640),
        center: true,
        titleBarStyle: TitleBarStyle.hidden,
        title: 'Othrys',
      );
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }

    final vaultResult = await EncryptionVault.instance.initialize();
    if (vaultResult.isFailure) {
      AppLogger.instance.error('Vault', 'Encryption vault initialization warning');
    }

    final prefs = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const OthrysApp(),
      ),
    );
  }, (error, stack) {
    AppLogger.instance.error('Uncaught', 'Uncaught async zone error: $error', error, stack);
  });
}
