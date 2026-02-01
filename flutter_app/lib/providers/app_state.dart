import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  // App-weite Zustände
  bool _isLoading = false;
  String _currentRoute = '/';
  Map<String, dynamic> _userData = {};

  // Getters
  bool get isLoading => _isLoading;
  String get currentRoute => _currentRoute;
  Map<String, dynamic> get userData => _userData;

  // Setters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }

  void updateUserData(Map<String, dynamic> data) {
    _userData = {..._userData, ...data};
    notifyListeners();
  }

  void clearUserData() {
    _userData = {};
    notifyListeners();
  }
}
