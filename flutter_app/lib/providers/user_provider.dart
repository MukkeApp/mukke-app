import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Map<String, dynamic> _userData = <String, dynamic>{};
  bool _isLoading = false;

  String? _lastErrorMessage;
  String? _lastErrorCode;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  Map<String, dynamic> get userData => _userData;
  bool get isLoading => _isLoading;

  String? get lastErrorMessage => _lastErrorMessage;
  String? get lastErrorCode => _lastErrorCode;

  User? get currentUser => _auth.currentUser;

  /// Appweit lokales User-Objekt aktualisieren
  void updateUserData(Map<String, dynamic> data) {
    _userData = <String, dynamic>{..._userData, ...data};
    notifyListeners();
  }

  /// Kompatibilität zu altem Code
  void setEmail(String email) => updateUserData({'email': email});
  void setName(String name) => updateUserData({'name': name});

  /// Lädt Userdaten aus Firestore.
  /// preferCache=true: zuerst Cache (vermeidet "unavailable" beim Screen-Start)
  Future<void> loadUserData({
    bool preferCache = true,
    bool listenToChanges = true,
  }) async {
    final user = _auth.currentUser;

    _lastErrorMessage = null;
    _lastErrorCode = null;

    if (user == null) {
      _userData = <String, dynamic>{};
      _isLoading = false;
      _stopListener();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final docRef = _firestore.collection('users').doc(user.uid);

    // 1) Cache (schnell, offline-freundlich)
    if (preferCache) {
      try {
        final cached = await docRef.get(const GetOptions(source: Source.cache));
        if (cached.exists) {
          final data = cached.data();
          if (data != null) {
            _userData = <String, dynamic>{
              ...data,
              'uid': user.uid,
              'email': user.email,
            };
            _isLoading = false;
            notifyListeners();
          }
        }
      } catch (_) {
        // Cache kann leer sein – ignorieren.
      }
    }

    // 2) Server (aktuell)
    try {
      final snap = await docRef.get(const GetOptions(source: Source.server));
      if (snap.exists) {
        final data = snap.data() ?? <String, dynamic>{};
        _userData = <String, dynamic>{
          ...data,
          'uid': user.uid,
          'email': user.email,
        };
      } else {
        // Erstdokument anlegen
        final base = <String, dynamic>{
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await docRef.set(base, SetOptions(merge: true));

        _userData = <String, dynamic>{
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? '',
          'photoUrl': user.photoURL,
        };
      }

      _lastErrorMessage = null;
      _lastErrorCode = null;
    } on FirebaseException catch (e) {
      _lastErrorCode = e.code;
      _lastErrorMessage = _firebaseMessage(e);

      _userData = _userData.isNotEmpty
          ? _userData
          : <String, dynamic>{
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
      };
    } catch (_) {
      _lastErrorCode = 'unknown';
      _lastErrorMessage = 'Profil konnte nicht geladen werden.';
      _userData = _userData.isNotEmpty
          ? _userData
          : <String, dynamic>{
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL,
      };
    } finally {
      _isLoading = false;
      notifyListeners();

      if (listenToChanges) {
        _startListener(user.uid);
      }
    }
  }

  /// Speichert Userdaten in Firestore (merge) UND aktualisiert lokal sofort.
  Future<void> saveUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    _lastErrorMessage = null;
    _lastErrorCode = null;

    if (user == null) {
      _lastErrorCode = 'not-authenticated';
      _lastErrorMessage = 'Du bist nicht eingeloggt.';
      notifyListeners();
      return;
    }

    // 1) Lokal sofort aktualisieren
    updateUserData(data);

    // 2) Firestore-Write (merge)
    final docRef = _firestore.collection('users').doc(user.uid);

    final payload = <String, dynamic>{
      ...data,
      'uid': user.uid,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(payload, SetOptions(merge: true));
      _lastErrorMessage = null;
      _lastErrorCode = null;
    } on FirebaseException catch (e) {
      _lastErrorCode = e.code;
      _lastErrorMessage = _firebaseMessage(e);
      // lokale Daten behalten
    } catch (_) {
      _lastErrorCode = 'unknown';
      _lastErrorMessage = 'Profil konnte nicht gespeichert werden.';
    } finally {
      notifyListeners();
    }
  }

  void clear() {
    _userData = <String, dynamic>{};
    _lastErrorMessage = null;
    _lastErrorCode = null;
    _stopListener();
    notifyListeners();
  }

  void _startListener(String uid) {
    _stopListener();
    _sub = _firestore.collection('users').doc(uid).snapshots().listen((snap) {
      if (!snap.exists) return;

      final data = snap.data();
      if (data == null) return;

      _userData = <String, dynamic>{
        ..._userData,
        ...data,
        'uid': uid,
        'email': _auth.currentUser?.email,
      };
      notifyListeners();
    }, onError: (_) {});
  }

  void _stopListener() {
    _sub?.cancel();
    _sub = null;
  }

  String _firebaseMessage(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
        return 'Dienst aktuell nicht verfügbar (unavailable). Prüfe Internet oder Firebase-Status.';
      case 'permission-denied':
        return 'Keine Berechtigung (permission-denied). Prüfe Firestore Rules.';
      case 'unauthenticated':
        return 'Nicht authentifiziert. Bitte neu einloggen.';
      case 'not-found':
        return 'Dokument nicht gefunden.';
      case 'deadline-exceeded':
        return 'Zeitüberschreitung. Bitte erneut versuchen.';
      default:
        return e.message ?? 'Firestore-Fehler: ${e.code}';
    }
  }
}
