/// Pure mapping: FirebaseAuthException.code -> user friendly message (DE).
/// Intentionally no Firebase imports so it can be unit-tested without plugin setup.
String mapFirebaseAuthErrorCodeToMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Bitte gib eine gültige E-Mail-Adresse ein.';
    case 'user-disabled':
      return 'Dieser Account wurde deaktiviert.';
    case 'user-not-found':
      return 'Kein Account mit dieser E-Mail gefunden.';
    case 'wrong-password':
      return 'Falsches Passwort.';
    case 'email-already-in-use':
      return 'Diese E-Mail ist bereits registriert.';
    case 'weak-password':
      return 'Das Passwort ist zu schwach (mind. 6 Zeichen).';
    case 'operation-not-allowed':
      return 'Login ist aktuell nicht erlaubt. Bitte prüfe die Firebase-Einstellungen.';
    case 'too-many-requests':
      return 'Zu viele Versuche. Bitte warte kurz und versuche es erneut.';
    case 'network-request-failed':
      return 'Netzwerkfehler. Bitte prüfe deine Verbindung.';
    case 'requires-recent-login':
      return 'Bitte melde dich erneut an, um diese Aktion auszuführen.';
    default:
      return 'Unbekannter Login-Fehler ($code).';
  }
}
