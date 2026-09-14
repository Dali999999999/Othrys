import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpsmanager/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SettingsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = SettingsService(prefs);
  });

  test('SettingsService initial state loads default values', () {
    final state = service.state;
    expect(state.themeMode, ThemeMode.system);
    expect(state.locale, isNull);
    expect(state.terminalFontSize, 14);
    expect(state.monitoringInterval, 3);
    expect(state.isFirstLaunch, isTrue);
  });

  test('SettingsService modifies and persists themeMode', () async {
    await service.setThemeMode(ThemeMode.dark);
    expect(service.state.themeMode, ThemeMode.dark);
    expect(prefs.getString(SettingsService.keyTheme), 'dark');

    await service.setThemeMode(ThemeMode.light);
    expect(service.state.themeMode, ThemeMode.light);
    expect(prefs.getString(SettingsService.keyTheme), 'light');
  });

  test('SettingsService modifies and persists locale', () async {
    await service.setLocale(const Locale('fr'));
    expect(service.state.locale?.languageCode, 'fr');
    expect(prefs.getString(SettingsService.keyLocale), 'fr');

    await service.setLocale(null);
    expect(service.state.locale, isNull);
    expect(prefs.getString(SettingsService.keyLocale), isNull);
  });

  test('SettingsService updates terminal font size and monitoring interval', () async {
    await service.setTerminalFontSize(16);
    expect(service.state.terminalFontSize, 16);
    expect(prefs.getInt(SettingsService.keyFontSize), 16);

    await service.setMonitoringInterval(10);
    expect(service.state.monitoringInterval, 10);
    expect(prefs.getInt(SettingsService.keyInterval), 10);
  });

  test('SettingsService marks first launch completed', () async {
    expect(service.state.isFirstLaunch, isTrue);
    await service.setFirstLaunchCompleted();
    expect(service.state.isFirstLaunch, isFalse);
    expect(prefs.getBool(SettingsService.keyFirstLaunch), isFalse);
  });
}
