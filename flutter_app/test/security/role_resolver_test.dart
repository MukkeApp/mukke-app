import 'package:flutter_test/flutter_test.dart';
import 'package:mukke_app/security/app_role.dart';
import 'package:mukke_app/security/boss_allowlist.dart';
import 'package:mukke_app/security/role_resolver.dart';

void main() {
  group('RoleResolver', () {
    test('boss via email allowlist (case-insensitive)', () {
      const allowlist = BossAllowlist(
        bossEmailsLower: <String>{'mapstar1588@web.de'},
      );
      const resolver = RoleResolver(allowlist);

      expect(
        resolver.resolve(email: 'MapStar1588@web.de', uid: 'u1'),
        AppRole.boss,
      );
    });

    test('boss via uid allowlist', () {
      const allowlist = BossAllowlist(bossUids: <String>{'UID123'});
      const resolver = RoleResolver(allowlist);

      expect(
        resolver.resolve(email: 'x@y.z', uid: 'UID123'),
        AppRole.boss,
      );
    });

    test('kidMode beats boss allowlist', () {
      const allowlist = BossAllowlist(
        bossEmailsLower: <String>{'mapstar1588@web.de'},
      );
      const resolver = RoleResolver(allowlist);

      expect(
        resolver.resolve(email: 'mapstar1588@web.de', uid: 'u1', kidMode: true),
        AppRole.kid,
      );
    });

    test('default user', () {
      const resolver = RoleResolver(BossAllowlist());
      expect(resolver.resolve(email: 'x@y.z', uid: ''), AppRole.user);
    });
  });
}
