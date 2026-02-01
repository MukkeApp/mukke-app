import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('de', 'DE');

  // Unterstützte Sprachen
  final Map<String, Map<String, String>> _supportedLanguages = {
    'de': {'name': 'Deutsch', 'flag': '🇩🇪', 'code': 'de_DE'},
    'en': {'name': 'English', 'flag': '🇬🇧', 'code': 'en_US'},
    'es': {'name': 'Español', 'flag': '🇪🇸', 'code': 'es_ES'},
    'fr': {'name': 'Français', 'flag': '🇫🇷', 'code': 'fr_FR'},
    'it': {'name': 'Italiano', 'flag': '🇮🇹', 'code': 'it_IT'},
    'tr': {'name': 'Türkçe', 'flag': '🇹🇷', 'code': 'tr_TR'},
    'ar': {'name': 'العربية', 'flag': '🇸🇦', 'code': 'ar_SA'},
    'ru': {'name': 'Русский', 'flag': '🇷🇺', 'code': 'ru_RU'},
    'pl': {'name': 'Polski', 'flag': '🇵🇱', 'code': 'pl_PL'},
  };

  // Zentraler Übersetzungs-Map
  static final Map<String, Map<String, String>> _translations = {
    'welcome': {
      'de': 'Willkommen',
      'en': 'Welcome',
      'es': 'Bienvenido',
      'fr': 'Bienvenue',
      'it': 'Benvenuto',
      'tr': 'Hoşgeldiniz',
      'ar': 'مرحبا',
      'ru': 'Добро пожаловать',
      'pl': 'Witamy',
    },
    'settings': {
      'de': 'Einstellungen',
      'en': 'Settings',
      'es': 'Configuración',
      'fr': 'Paramètres',
      'it': 'Impostazioni',
      'tr': 'Ayarlar',
      'ar': 'الإعدادات',
      'ru': 'Настройки',
      'pl': 'Ustawienia',
    },
    'profile': {
      'de': 'Profil',
      'en': 'Profile',
      'es': 'Perfil',
      'fr': 'Profil',
      'it': 'Profilo',
      'tr': 'Profil',
      'ar': 'الملف الشخصي',
      'ru': 'Профиль',
      'pl': 'Profil',
    },
    'logout': {
      'de': 'Abmelden',
      'en': 'Logout',
      'es': 'Cerrar sesión',
      'fr': 'Déconnexion',
      'it': 'Disconnetti',
      'tr': 'Çıkış',
      'ar': 'تسجيل الخروج',
      'ru': 'Выйти',
      'pl': 'Wyloguj',
    },
    'home': {
      'de': 'Startseite',
      'en': 'Home',
      'es': 'Inicio',
      'fr': 'Accueil',
      'it': 'Home',
      'tr': 'Ana Sayfa',
      'ar': 'الرئيسية',
      'ru': 'Главная',
      'pl': 'Strona główna',
    },
    'login': {
      'de': 'Anmelden',
      'en': 'Login',
      'es': 'Iniciar sesión',
      'fr': 'Connexion',
      'it': 'Accedi',
      'tr': 'Giriş Yap',
      'ar': 'تسجيل الدخول',
      'ru': 'Войти',
      'pl': 'Zaloguj się',
    },
    'register': {
      'de': 'Registrieren',
      'en': 'Register',
      'es': 'Registrarse',
      'fr': 'S’inscrire',
      'it': 'Registrati',
      'tr': 'Kayıt Ol',
      'ar': 'التسجيل',
      'ru': 'Регистрация',
      'pl': 'Zarejestruj się',
    },
  };

  // Getters
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  String get currentLanguageName =>
      _supportedLanguages[_currentLocale.languageCode]?['name'] ?? 'Deutsch';
  String get currentLanguageFlag =>
      _supportedLanguages[_currentLocale.languageCode]?['flag'] ?? '🇩🇪';
  Map<String, Map<String, String>> get supportedLanguages =>
      _supportedLanguages;

  // Sprache ändern
  void changeLanguage(String languageCode) {
    if (_supportedLanguages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  // Sprache mit Locale ändern
  void setLocale(Locale locale) {
    if (_supportedLanguages.containsKey(locale.languageCode)) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  // Übersetzungslogik
  String translate(String key) {
    return _translations[key]?[currentLanguageCode] ?? key;
  }

  // Liste aller verfügbaren Sprachen für UI
  List<Map<String, String>> get languagesList {
    return _supportedLanguages.entries.map((entry) {
      return {
        'code': entry.key,
        'name': entry.value['name']!,
        'flag': entry.value['flag']!,
      };
    }).toList();
  }
}
