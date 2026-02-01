import 'package:firebase_auth/firebase_auth.dart';
import 'auth_error_mapper.dart';

class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = _normalizeEmail(email);
    _validateEmailPassword(cleanEmail, password);

    try {
      await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, mapFirebaseAuthErrorCodeToMessage(e.code));
    } catch (_) {
      throw AuthException('unknown', 'Unbekannter Fehler beim Anmelden.');
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cleanEmail = _normalizeEmail(email);
    _validateEmailPassword(cleanEmail, password);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final name = (displayName ?? '').trim();
      if (name.isNotEmpty) {
        await credential.user?.updateDisplayName(name);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, mapFirebaseAuthErrorCodeToMessage(e.code));
    } catch (_) {
      throw AuthException('unknown', 'Unbekannter Fehler beim Registrieren.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = _normalizeEmail(email);
    if (cleanEmail.isEmpty) {
      throw AuthException('invalid-input', 'Bitte gib eine E-Mail-Adresse ein.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, mapFirebaseAuthErrorCodeToMessage(e.code));
    } catch (_) {
      throw AuthException('unknown', 'Unbekannter Fehler beim Zurücksetzen des Passworts.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- helpers
  String _normalizeEmail(String email) => email.trim().toLowerCase();

  void _validateEmailPassword(String email, String password) {
    if (email.isEmpty) {
      throw AuthException('invalid-input', 'Bitte gib eine E-Mail-Adresse ein.');
    }
    if (password.isEmpty) {
      throw AuthException('invalid-input', 'Bitte gib ein Passwort ein.');
    }
    if (password.length < 6) {
      throw AuthException('invalid-input', 'Passwort muss mindestens 6 Zeichen lang sein.');
    }
  }
}
