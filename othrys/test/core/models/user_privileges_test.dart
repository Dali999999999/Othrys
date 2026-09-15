import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/models/user_privileges_entity.dart';

void main() {
  group('UserPrivileges', () {
    test('parses root user correctly', () {
      const raw = '0\nroot\nroot\nSUDO:YES\n';
      final priv = UserPrivileges.fromRaw(raw);

      expect(priv.uid, 0);
      expect(priv.username, 'root');
      expect(priv.groups, ['root']);
      expect(priv.canSudoWithoutPassword, isTrue);
      expect(priv.isRoot, isTrue);
      expect(priv.role, UserRole.root);
      expect(priv.canManageSystem, isTrue);
      expect(priv.canManageDocker, isTrue);
    });

    test('parses sudoer user (e.g. ubuntu with passwordless sudo)', () {
      const raw = '1000\r\nubuntu\r\nubuntu adm sudo docker\r\nSUDO:YES\r\n';
      final priv = UserPrivileges.fromRaw(raw);

      expect(priv.uid, 1000);
      expect(priv.username, 'ubuntu');
      expect(priv.groups, ['ubuntu', 'adm', 'sudo', 'docker']);
      expect(priv.canSudoWithoutPassword, isTrue);
      expect(priv.isRoot, isFalse);
      expect(priv.hasDockerGroup, isTrue);
      expect(priv.role, UserRole.sudoer);
      expect(priv.canManageSystem, isTrue);
      expect(priv.canManageDocker, isTrue);
    });

    test('parses docker group user without sudo privileges', () {
      const raw = '1001\ndeploy\ndeploy docker developers\nSUDO:NO\n';
      final priv = UserPrivileges.fromRaw(raw);

      expect(priv.uid, 1001);
      expect(priv.username, 'deploy');
      expect(priv.groups, ['deploy', 'docker', 'developers']);
      expect(priv.canSudoWithoutPassword, isFalse);
      expect(priv.isRoot, isFalse);
      expect(priv.hasDockerGroup, isTrue);
      expect(priv.role, UserRole.standard);
      expect(priv.canManageSystem, isFalse);
      expect(priv.canManageDocker, isTrue);
    });

    test('parses standard unprivileged user', () {
      const raw = '1002\nintern\nintern users\nSUDO:NO\n';
      final priv = UserPrivileges.fromRaw(raw);

      expect(priv.uid, 1002);
      expect(priv.username, 'intern');
      expect(priv.groups, ['intern', 'users']);
      expect(priv.canSudoWithoutPassword, isFalse);
      expect(priv.isRoot, isFalse);
      expect(priv.hasDockerGroup, isFalse);
      expect(priv.role, UserRole.standard);
      expect(priv.canManageSystem, isFalse);
      expect(priv.canManageDocker, isFalse);
    });

    test('handles empty or malformed output gracefully', () {
      final priv = UserPrivileges.fromRaw('');
      expect(priv.uid, -1);
      expect(priv.username, 'unknown');
      expect(priv.groups, isEmpty);
      expect(priv.isRoot, isFalse);
      expect(priv.role, UserRole.standard);
      expect(priv.canManageSystem, isFalse);
      expect(priv.canManageDocker, isFalse);
    });

    test('equality and hashCode contract', () {
      const priv1 = UserPrivileges(
        uid: 1000,
        username: 'alice',
        groups: ['alice', 'sudo'],
        canSudoWithoutPassword: true,
      );
      const priv2 = UserPrivileges(
        uid: 1000,
        username: 'alice',
        groups: ['alice', 'sudo'],
        canSudoWithoutPassword: true,
      );
      const priv3 = UserPrivileges(
        uid: 1001,
        username: 'bob',
        groups: ['bob'],
        canSudoWithoutPassword: false,
      );

      expect(priv1, equals(priv2));
      expect(priv1.hashCode, equals(priv2.hashCode));
      expect(priv1, isNot(equals(priv3)));
      expect(priv1.toString(), contains('alice'));
    });
  });
}
