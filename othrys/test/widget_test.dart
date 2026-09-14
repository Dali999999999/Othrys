import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpsmanager/app/app.dart';
import 'package:vpsmanager/core/services/settings_service.dart';

void main() {
  testWidgets('OthrysApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'settings_first': false});
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const OthrysApp(),
      ),
    );
    expect(find.byType(OthrysApp), findsOneWidget);
  });
}
