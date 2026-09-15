import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/services/app_update_service.dart';

void main() {
  group('AppUpdateService - Version Comparison Unit Tests', () {
    test('isNewerVersion correctly compares semver versions', () {
      // Patch bump
      expect(AppUpdateService.isNewerVersion('0.1.1', '0.1.0'), isTrue);
      // Minor bump
      expect(AppUpdateService.isNewerVersion('0.2.0', '0.1.9'), isTrue);
      // Major bump
      expect(AppUpdateService.isNewerVersion('1.0.0', '0.9.9'), isTrue);
      // Equal versions
      expect(AppUpdateService.isNewerVersion('0.1.0', '0.1.0'), isFalse);
      // Older versions
      expect(AppUpdateService.isNewerVersion('0.0.9', '0.1.0'), isFalse);
      expect(AppUpdateService.isNewerVersion('0.1.0', '0.2.0'), isFalse);
      // Versions with prefixes or build metadata
      expect(AppUpdateService.isNewerVersion('0.1.1+5', '0.1.0+1'), isTrue);
      expect(AppUpdateService.isNewerVersion('0.1.1-beta', '0.1.0'), isTrue);
    });

    test('AppUpdateState copyWith retains and updates fields correctly', () {
      const initial = AppUpdateState();
      expect(initial.isChecking, isFalse);
      expect(initial.isDownloading, isFalse);
      expect(initial.downloadProgress, 0.0);
      expect(initial.availableUpdate, isNull);
      expect(initial.userDismissed, isFalse);

      final updated = initial.copyWith(
        isChecking: true,
        isDownloading: true,
        downloadProgress: 0.5,
        userDismissed: true,
      );

      expect(updated.isChecking, isTrue);
      expect(updated.isDownloading, isTrue);
      expect(updated.downloadProgress, 0.5);
      expect(updated.userDismissed, isTrue);
    });

    test('AppUpdateService dismisses banner properly', () {
      final service = AppUpdateService();
      expect(service.state.userDismissed, isFalse);

      service.dismissBanner();
      expect(service.state.userDismissed, isTrue);
    });
  });
}
