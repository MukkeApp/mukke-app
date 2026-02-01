import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Benutzerregistrierung mit E-Mail und Passwort
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Benutzerprofil in Firestore speichern
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception("Registrierung fehlgeschlagen: ${e.message}");
    } catch (e) {
      throw Exception("Unbekannter Fehler bei der Registrierung: $e");
    }
  }

  // Benutzeranmeldung mit E-Mail und Passwort
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception("Login fehlgeschlagen: ${e.message}");
    } catch (e) {
      throw Exception("Unbekannter Fehler beim Login: $e");
    }
  }

  // Aktuell angemeldeter Benutzer
  User? get currentUser => _auth.currentUser;

  // Benutzer abmelden
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Benutzerprofil aus Firestore abrufen
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception("Fehler beim Laden des Benutzerprofils: $e");
    }
  }

  // Benutzerprofil aktualisieren
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Fehler beim Aktualisieren des Benutzerprofils: $e");
    }
  }

  // Benutzer löschen
  Future<void> deleteUser() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception("Benutzer konnte nicht gelöscht werden: ${e.message}");
    } catch (e) {
      throw Exception("Unbekannter Fehler beim Löschen des Benutzers: $e");
    }
  }
}
