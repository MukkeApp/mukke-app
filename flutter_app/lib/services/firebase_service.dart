import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Fehlender Import ergänzt

class FirebaseService {
  // Wir nutzen die App, die in main.dart initialisiert wurde
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  FirebaseService();

  // Beispiel-Methode: User-Daten speichern
  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Beispiel-Methode: User-Daten laden
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await firestore.collection('users').doc(uid).get();
  }

  // Beispiel-Methode: User löschen
  Future<void> deleteUser(String uid) async {
    await firestore.collection('users').doc(uid).delete();
    final user = auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.delete();
    }
  }

  // ✅ Nur wenn du wirklich die App brauchst
  FirebaseApp getAppInstance() {
    return Firebase.app();
  }
}
