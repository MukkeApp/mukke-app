import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mukke_app/screens/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mukke_app/widgets/boss_guard.dart';
import 'package:mukke_app/screens/boss_panel_screen.dart';

// Firebase Options
import 'services/firebase_options.dart';

// Services
import 'services/firebase_service.dart';
import 'services/jarviz_service.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/notification_service.dart';

// Providers
import 'providers/app_state.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

// Screens
import 'screens/mukke_music_screen.dart';
import 'screens/ki_music_screen.dart';
import 'screens/dating_profile_screen.dart';
import 'screens/mukke_sport_screen.dart';
import 'screens/mukke_realchallenge_screen.dart';
import 'screens/mukke_games_screen.dart';
import 'screens/mukke_avatar_screen.dart';
import 'screens/mukke_tracking_screen.dart';
import 'screens/mukke_fashion_screen.dart';
import 'screens/mukke_language_screen.dart';
import 'screens/mukke_live_screen.dart';
import 'screens/mukke_feedback_screen.dart';
import 'screens/account_linking_screen.dart';
import 'screens/agb_screen.dart';

// Utils
import 'utils/error_handler.dart';

// >>> AuthGate + RegisterScreen (für Login-/Register-Routen)
import 'auth_gate.dart';
import 'screens/register_screen_.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env laden
  await dotenv.load(fileName: ".env");

  // UI Setup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Orientation Setup
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase Initialization mit Hot Restart Schutz
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase wurde erfolgreich initialisiert');
    } else {
      debugPrint('ℹ️ Firebase App existiert bereits');
    }

    // Notification Service nur initialisieren wenn Firebase bereit ist
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('⚠️ NotificationService Initialisierung fehlgeschlagen: $e');
    }

    // Error Handler
    ErrorHandler.attach();
  } catch (e) {
    debugPrint('❌ Firebase Initialisierungsfehler: $e');
  }

  runApp(const MukkeApp());
}

class MukkeApp extends StatelessWidget {
  const MukkeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider()),
        Provider<FirebaseService>(create: (_) => FirebaseService()),
        Provider<JarvizService>(create: (_) => JarvizService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<PaymentService>(create: (_) => PaymentService()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'MukkeApp',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('de', 'DE'),
              Locale('en', 'US'),
              Locale('es', 'ES'),
              Locale('fr', 'FR'),
              Locale('it', 'IT'),
              Locale('tr', 'TR'),
              Locale('ar', 'SA'),
              Locale('ru', 'RU'),
              Locale('pl', 'PL'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Start über AuthGate; KEINE "/"-Route parallel definieren
            home: const AuthGate(),

            routes: _routes,
            onGenerateRoute: _generateRoute,
            builder: (context, child) {
              // Error Widget für bessere Fehlerbehandlung
              ErrorWidget.builder = (errorDetails) {
                return Scaffold(
                  backgroundColor: AppColors.background,
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ein Fehler ist aufgetreten',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorDetails.exception.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              };
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> get _routes => {
    // ⚠️ KEIN AppRoutes.home ('/') hier!
    AppRoutes.profile: (context) => const ProfileScreen(),
    AppRoutes.music: (context) => const MukkeMusicScreen(),
    AppRoutes.kiMusic: (context) => const KiMusicScreen(),
    AppRoutes.dating: (context) => const DatingProfileScreen(),
    AppRoutes.sport: (context) => const MukkeSportScreen(),
    AppRoutes.challenges: (context) => const MukkeRealChallengeScreen(),
    AppRoutes.games: (context) => const MukkeGamesScreen(),
    AppRoutes.avatar: (context) => const MukkeAvatarScreen(),
    AppRoutes.tracking: (context) => const MukkeTrackingScreen(),
    AppRoutes.fashion: (context) => const MukkeFashionScreen(),
    AppRoutes.language: (context) => const MukkeLanguageScreen(),
    AppRoutes.live: (context) => const MukkeLiveScreen(),

    // ✅ 3c2: Boss Route korrekt (BossGuard schützt)
    AppRoutes.boss: (context) => const BossGuard(
      child: BossPanelScreen(),
    ),

    AppRoutes.feedback: (context) => const MukkeFeedbackScreen(),
    AppRoutes.accountLinking: (context) => AccountLinkingScreen(
      socialLinks: const {},
      onUpdate: (_) {},
    ),
    AppRoutes.agb: (context) => const AGBScreen(),

    // >>> Ergänzt/angepasst: explizite Routen zum Öffnen der Seite in gewünschtem Modus
    '/register': (context) =>
    const RegisterScreen(initialMode: AuthFormMode.signup),
    '/login': (context) =>
    const RegisterScreen(initialMode: AuthFormMode.login),
  };

  Route<dynamic> _generateRoute(RouteSettings settings) {
    return _buildRoute(
      Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Seite nicht gefunden: ${settings.name}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // Statt '/': zurück ins AuthGate
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Zurück zum Start'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class AppRoutes {
  static const String home =
      '/'; // bleibt definiert, wird aber NICHT in routes benutzt
  static const String profile = '/profile';
  static const String music = '/music';
  static const String kiMusic = '/music/ki';
  static const String dating = '/dating';
  static const String sport = '/sport';
  static const String challenges = '/challenges';
  static const String games = '/games';
  static const String avatar = '/avatar';
  static const String tracking = '/tracking';
  static const String fashion = '/fashion';
  static const String language = '/language';
  static const String live = '/live';
  static const String feedback = '/feedback';
  static const String accountLinking = '/account-linking';
  static const String agb = '/agb';

  // ✅ 3c2: Boss Route-Konstante
  static const String boss = '/boss';
}

class AppColors {
  static const Color primary = Color(0xFF00BFFF);
  static const Color accent = Color(0xFFFF1493);
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2D2D2D);
  static const Color surfaceDark = Color(0xFF252525);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}
