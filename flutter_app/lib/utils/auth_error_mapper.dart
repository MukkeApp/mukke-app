/// Mappt FirebaseAuth-Errorcodes auf deutsche Fehlermeldungen.
///
/// Referenz: FirebaseAuthException.code
String mapFirebaseAuthErrorCodeToMessage(String code) {
  switch (code) {
  // Sign-in
    case 'invalid-email':
      return 'Bitte gib eine gültige E-Mail-Adresse ein.';
    case 'user-disabled':
      return 'Dieses Konto wurde deaktiviert.';
    case 'user-not-found':
      return 'Kein Konto mit dieser E-Mail gefunden.';
    case 'wrong-password':
      return 'Falsches Passwort.';
    case 'invalid-credential':
      return 'E-Mail oder Passwort ist falsch.';
    case 'too-many-requests':
      return 'Zu viele Versuche. Bitte später erneut probieren.';
    case 'network-request-failed':
      return 'Netzwerkfehler. Bitte Internetverbindung prüfen.';

  // Sign-up
    case 'email-already-in-use':
      return 'Diese E-Mail ist bereits registriert.';
    case 'weak-password':
      return 'Das Passwort ist zu schwach (mind. 6 Zeichen empfohlen).';
    case 'operation-not-allowed':
      return 'E-Mail/Passwort Login ist im Firebase-Projekt nicht aktiviert.';

  // Password reset
    case 'missing-email':
      return 'Bitte gib eine E-Mail-Adresse ein.';

    default:
      return 'Anmeldung fehlgeschlagen ($code).';
  }
}

/// Einheitliche Exception für Auth-Fehler in der App.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Backwards-Compatibility (falls irgendwo noch der alte Name genutzt wird).
@Deprecated('Use mapFirebaseAuthErrorCodeToMessage')
String mapAuthCodeToDeMessage(String code) => mapFirebaseAuthErrorCodeToMessage(code);
