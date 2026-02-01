import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  // User-Daten
  String? _userId;
  String? _userName;
  String? _userEmail;
  String? _profilePicture;
  bool _isPremium = false;
  List<String> _favoriteFeatures = [];
  Map<String, dynamic> _userData = {};

  // Getters
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get profilePicture => _profilePicture;
  bool get isPremium => _isPremium;
  List<String> get favoriteFeatures => _favoriteFeatures;
  Map<String, dynamic> get userData => _userData;
  bool get isLoggedIn => _userId != null;

  // User einloggen
  void login({
    required String userId,
    required String userName,
    required String userEmail,
    String? profilePicture,
    bool isPremium = false,
  }) {
    _userId = userId;
    _userName = userName;
    _userEmail = userEmail;
    _profilePicture = profilePicture;
    _isPremium = isPremium;
    _userData = {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'profilePicture': profilePicture,
      'isPremium': isPremium,
    };
    notifyListeners();
  }

  // User ausloggen
  void logout() {
    _userId = null;
    _userName = null;
    _userEmail = null;
    _profilePicture = null;
    _isPremium = false;
    _favoriteFeatures = [];
    _userData = {};
    notifyListeners();
  }

  // User-Daten aktualisieren
  void updateUserData(Map<String, Object?> profileData) {
    // Update internal fields
    if (profileData.containsKey('userName')) {
      _userName = profileData['userName'] as String?;
    }
    if (profileData.containsKey('userEmail')) {
      _userEmail = profileData['userEmail'] as String?;
    }
    if (profileData.containsKey('profilePicture')) {
      _profilePicture = profileData['profilePicture'] as String?;
    }
    if (profileData.containsKey('isPremium')) {
      _isPremium = profileData['isPremium'] as bool? ?? false;
    }
    
    // Update userData map
    _userData = {..._userData, ...profileData};
    notifyListeners();
  }

  // Premium Status updaten
  void updatePremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    _userData['isPremium'] = isPremium;
    notifyListeners();
  }

  // Favoriten verwalten
  void addFavoriteFeature(String feature) {
    if (!_favoriteFeatures.contains(feature)) {
      _favoriteFeatures.add(feature);
      _userData['favoriteFeatures'] = _favoriteFeatures;
      notifyListeners();
    }
  }

  void removeFavoriteFeature(String feature) {
    _favoriteFeatures.remove(feature);
    _userData['favoriteFeatures'] = _favoriteFeatures;
    notifyListeners();
  }
}