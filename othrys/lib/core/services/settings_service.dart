import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable state holding application-level user preferences.
class SettingsState {
  final ThemeMode themeMode;
  final Locale? locale;
  final int terminalFontSize;
  final int monitoringInterval;
  final bool isFirstLaunch;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.terminalFontSize = 14,
    this.monitoringInterval = 3,
    this.isFirstLaunch = true,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    int? terminalFontSize,
    int? monitoringInterval,
    bool? isFirstLaunch,
  }) => SettingsState(
    themeMode: themeMode ?? this.themeMode,
    locale: locale != null ? locale() : this.locale,
    terminalFontSize: terminalFontSize ?? this.terminalFontSize,
    monitoringInterval: monitoringInterval ?? this.monitoringInterval,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
  );
}

/// Controller managing persistent user preferences via SharedPreferences.
class SettingsService extends StateNotifier<SettingsState> {
  final SharedPreferences prefs;
  SettingsService(this.prefs) : super(const SettingsState()) { _load(); }

  static const keyTheme = 'settings_theme', keyLocale = 'settings_locale';
  static const keyFontSize = 'settings_font_size', keyInterval = 'settings_interval', keyFirstLaunch = 'settings_first';

  void _load() {
    final t = prefs.getString(keyTheme);
    final theme = t == 'dark' ? ThemeMode.dark : t == 'light' ? ThemeMode.light : ThemeMode.system;
    final l = prefs.getString(keyLocale);
    final loc = l == 'fr' ? const Locale('fr') : l == 'en' ? const Locale('en') : null;
    state = SettingsState(
      themeMode: theme,
      locale: loc,
      terminalFontSize: prefs.getInt(keyFontSize) ?? 14,
      monitoringInterval: prefs.getInt(keyInterval) ?? 3,
      isFirstLaunch: prefs.getBool(keyFirstLaunch) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode m) async {
    await prefs.setString(keyTheme, m == ThemeMode.dark ? 'dark' : m == ThemeMode.light ? 'light' : 'system');
    state = state.copyWith(themeMode: m);
  }

  Future<void> setLocale(Locale? l) async {
    if (l == null) { await prefs.remove(keyLocale); state = state.copyWith(locale: () => null); }
    else { await prefs.setString(keyLocale, l.languageCode); state = state.copyWith(locale: () => l); }
  }

  Future<void> setTerminalFontSize(int s) async { await prefs.setInt(keyFontSize, s); state = state.copyWith(terminalFontSize: s); }
  Future<void> setMonitoringInterval(int s) async { await prefs.setInt(keyInterval, s); state = state.copyWith(monitoringInterval: s); }
  Future<void> setFirstLaunchCompleted() async { await prefs.setBool(keyFirstLaunch, false); state = state.copyWith(isFirstLaunch: false); }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('Override in root'));
final settingsServiceProvider = StateNotifierProvider<SettingsService, SettingsState>((ref) => SettingsService(ref.watch(sharedPreferencesProvider)));
