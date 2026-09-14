import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/features/file_manager/file_manager_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FileManagerState initial state has default path and empty items', () {
    const state = FileManagerState();
    expect(state.currentPath, '.');
    expect(state.items, isEmpty);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('FileManagerController identifies binary files correctly', () {
    expect(FileManagerController.isBinary('archive.tar.gz'), isTrue);
    expect(FileManagerController.isBinary('photo.png'), isTrue);
    expect(FileManagerController.isBinary('binary.so'), isTrue);
    expect(FileManagerController.isBinary('config.yaml'), isFalse);
    expect(FileManagerController.isBinary('script.sh'), isFalse);
    expect(FileManagerController.isBinary('Dockerfile'), isFalse);
  });

  test('FileManagerController rejects binary files from reading', () async {
    final controller = FileManagerController(sshManager: SSHSessionManager.instance);
    const binaryItem = FileEntryEntity(
      name: 'firmware.bin',
      path: '/root/firmware.bin',
      isDirectory: false,
      size: 512,
    );

    final result = await controller.readFileContent('session-1', binaryItem);
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message.contains('binary'), isTrue);
  });

  test('FileManagerController rejects files exceeding 1 MB safety guard', () async {
    final controller = FileManagerController(sshManager: SSHSessionManager.instance);
    const largeItem = FileEntryEntity(
      name: 'large_log.txt',
      path: '/var/log/large_log.txt',
      isDirectory: false,
      size: 2 * 1024 * 1024, // 2 MB
    );

    final result = await controller.readFileContent('session-1', largeItem);
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message.contains('1 MB safety limit'), isTrue);
  });

  test('FileManagerController upload rejects non-existing local file', () async {
    final controller = FileManagerController(sshManager: SSHSessionManager.instance);
    final result = await controller.uploadFile(
      'session-1',
      'C:/non_existing_file_path_12345.txt',
      '/tmp',
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.message.contains('does not exist'), isTrue);
  });

  test('FileManagerController download rejects directory and oversized files', () async {
    final controller = FileManagerController(sshManager: SSHSessionManager.instance);
    const dirItem = FileEntryEntity(
      name: 'folder',
      path: '/var/folder',
      isDirectory: true,
      size: 4096,
    );
    final dirResult = await controller.downloadFile('session-1', dirItem, 'C:/temp/out.txt');
    expect(dirResult.isFailure, isTrue);
    expect(dirResult.failureOrNull?.message.contains('Cannot download a directory'), isTrue);

    const oversizedItem = FileEntryEntity(
      name: 'huge.iso',
      path: '/var/huge.iso',
      isDirectory: false,
      size: 150 * 1024 * 1024, // 150 MB
    );
    final oversizedResult = await controller.downloadFile('session-1', oversizedItem, 'C:/temp/huge.iso');
    expect(oversizedResult.isFailure, isTrue);
    expect(oversizedResult.failureOrNull?.message.contains('100 MB download limit'), isTrue);
  });

  test('FileManagerController rename handles missing session gracefully', () async {
    final controller = FileManagerController(sshManager: SSHSessionManager.instance);
    final result = await controller.renameEntry('invalid-session', '/tmp/old.txt', '/tmp/new.txt');
    expect(result.isFailure, isTrue);
  });
}
