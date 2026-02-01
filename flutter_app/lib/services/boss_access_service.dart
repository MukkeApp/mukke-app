import 'package:firebase_auth/firebase_auth.dart';

/// Boss-only Zugriff: ausschließlich Florian Schulz.
/// MVP v1: Whitelist über E-Mail (später upgrade auf Custom Claims/Firestore).
class BossAccessService {
  // Florian Schulz (Boss) – von dir geliefert:
  static const String bossEmail = 'Mapstar1588@web.de';

  bool isBoss(User? user) => isBossEmail(user?.email);

  /// Extra Helper, damit wir es sauber testen können (ohne Firebase User zu mocken).
  bool isBossEmail(String? email) {
    final normalized = email?.toLowerCase().trim();
    return normalized != null && normalized == bossEmail.toLowerCase();
  }
}
