import 'app_role.dart';
import 'boss_allowlist.dart';

class RoleResolver {
  final BossAllowlist allowlist;

  const RoleResolver(this.allowlist);

  /// kidMode ist vorbereitet (echte Einschränkungen kommen später).
  AppRole resolve({
    required String? email,
    required String? uid,
    bool kidMode = false,
  }) {
    if (kidMode) return AppRole.kid;
    if (allowlist.isBoss(email: email, uid: uid)) return AppRole.boss;
    return AppRole.user;
  }

  bool isBoss({required String? email, required String? uid}) {
    return resolve(email: email, uid: uid) == AppRole.boss;
  }
}
