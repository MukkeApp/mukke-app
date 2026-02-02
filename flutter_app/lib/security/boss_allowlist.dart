import 'package:flutter_dotenv/flutter_dotenv.dart';

class BossAllowlist {
  final Set<String> bossEmailsLower;
  final Set<String> bossUids;

  const BossAllowlist({
    this.bossEmailsLower = const <String>{},
    this.bossUids = const <String>{},
  });

  /// Erwartete .env Keys:
  /// - BOSS_EMAILS: Komma/Whitespace-separiert (empfohlen)
  /// - BOSS_UIDS:   Komma/Whitespace-separiert (optional)
  factory BossAllowlist.fromEnv({
    String emailKey = 'BOSS_EMAILS',
    String uidKey = 'BOSS_UIDS',
  }) {
    final emailsRaw = dotenv.env[emailKey] ?? '';
    final uidsRaw = dotenv.env[uidKey] ?? '';

    final emails = _split(emailsRaw).map((e) => e.toLowerCase()).toSet();
    final uids = _split(uidsRaw).toSet();

    return BossAllowlist(bossEmailsLower: emails, bossUids: uids);
  }

  bool isBoss({String? email, String? uid}) {
    final uidNorm = uid?.trim();
    if (uidNorm != null && uidNorm.isNotEmpty && bossUids.contains(uidNorm)) {
      return true;
    }

    final emailNorm = email?.trim().toLowerCase();
    if (emailNorm != null &&
        emailNorm.isNotEmpty &&
        bossEmailsLower.contains(emailNorm)) {
      return true;
    }

    return false;
  }

  static Iterable<String> _split(String raw) {
    return raw
        .split(RegExp(r'[,\n; ]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
  }
}
