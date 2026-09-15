import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/features/splash/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Otrhys Native Animation Splash Screen Tests', () {
    testWidgets('SplashScreen mounts and renders animation container',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Completes automatically when duration elapses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            duration: const Duration(milliseconds: 4000),
            onAnimationComplete: () {
              completed = true;
            },
          ),
        ),
      );

      expect(completed, isFalse);

      await tester.pump(const Duration(milliseconds: 4000));
      expect(completed, isTrue);
    });

    testWidgets('Skip animation via keyboard shortcut (Space/Enter/Escape)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              completed = true;
            },
          ),
        ),
      );

      // Press Space to skip
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(completed, isTrue);
    });

    testWidgets('Skip animation via tap gesture',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () {
              completed = true;
            },
          ),
        ),
      );

      // Tap on screen to skip
      await tester.tap(find.byType(SplashScreen));
      await tester.pump();

      expect(completed, isTrue);
    });
  });
}
