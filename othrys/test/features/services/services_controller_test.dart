import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/network/ssh_session_manager.dart';
import 'package:othrys/features/services/services_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ServicesState initial state is empty', () {
    const state = ServicesState();
    expect(state.services, isEmpty);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('ServiceEntryEntity parses and identifies running and boot-enabled state correctly', () {
    const service = ServiceEntryEntity(
      unit: 'nginx.service',
      load: 'loaded',
      active: 'active',
      sub: 'running',
      description: 'A high performance web server',
      isEnabled: true,
    );

    expect(service.isRunning, isTrue);
    expect(service.isEnabled, isTrue);
    expect(service.unit, 'nginx.service');

    final disabledCopy = service.copyWith(isEnabled: false);
    expect(disabledCopy.isEnabled, isFalse);
    expect(disabledCopy.isRunning, isTrue);
  });

  test('ServicesController rejects disallowed systemctl actions', () async {
    final controller = ServicesController(sshManager: SSHSessionManager.instance);
    const service = ServiceEntryEntity(
      unit: 'test.service',
      load: 'loaded',
      active: 'active',
      sub: 'running',
      description: 'Test',
    );

    final result = await controller.executeServiceAction('session-1', service, 'destroy_world');
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message.contains('Disallowed systemctl action'), isTrue);
  });

  test('ServicesController rejects malicious characters in service unit name', () async {
    final controller = ServicesController(sshManager: SSHSessionManager.instance);
    const dangerousService = ServiceEntryEntity(
      unit: 'nginx; rm -rf /',
      load: 'loaded',
      active: 'active',
      sub: 'running',
      description: 'Dangerous',
    );

    final result = await controller.enableService('session-1', dangerousService);
    expect(result.isFailure, isTrue);
  });

  test('ServicesController handles missing session gracefully for journal logs and actions', () async {
    final controller = ServicesController(sshManager: SSHSessionManager.instance);
    const service = ServiceEntryEntity(
      unit: 'nginx.service',
      load: 'loaded',
      active: 'active',
      sub: 'running',
      description: 'Test',
    );

    final enableRes = await controller.enableService('invalid-session', service);
    expect(enableRes.isFailure, isTrue);

    final disableRes = await controller.disableService('invalid-session', service);
    expect(disableRes.isFailure, isTrue);

    final logsRes = await controller.getJournalLogs('invalid-session', service.unit);
    expect(logsRes.isFailure, isTrue);
  });
}
