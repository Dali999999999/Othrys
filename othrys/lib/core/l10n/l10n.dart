import 'package:flutter/widgets.dart';
import 'arb/app_localizations.dart';

export 'arb/app_localizations.dart';

/// Convenient extension on BuildContext to quickly access localized strings.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
