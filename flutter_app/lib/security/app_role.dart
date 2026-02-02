enum AppRole { boss, user, kid }

extension AppRoleX on AppRole {
  bool get isBoss => this == AppRole.boss;
  bool get isKid => this == AppRole.kid;
}
