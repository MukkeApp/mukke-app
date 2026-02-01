import 'package:firebase_auth/firebase_auth.dart';
import 'package:mukke_app/utils/auth_error_mapper.dart';

// Damit Screens weiterhin nur AuthService importieren müssen und trotzdem
// AuthException verfügbar ist:
export 'package:mukke_app/utils/auth_error_mapper.dart' show AuthException;

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCodeToMessage(e.code));
    }
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final name = (displayName ?? '').trim();
      if (name.isNotEmpty) {
        await credential.user?.updateDisplayName(name);
        await credential.user?.reload();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCodeToMessage(e.code));
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(mapFirebaseAuthErrorCodeToMessage(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();
}
