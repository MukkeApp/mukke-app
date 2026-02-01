import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple .env wrapper so you can keep using `Env.*` everywhere.
/// Be sure to call `await dotenv.load(fileName: ".env");` in `main()` before `runApp()`.
class Env {
  // ===== OpenAI =====
  static String get openAiApiKey => dotenv.maybeGet('OPENAI_API_KEY') ?? '';

  // ===== Firebase =====
  static String get firebaseApiKey => dotenv.maybeGet('FIREBASE_API_KEY') ?? '';
  static String get firebaseAuthDomain =>
      dotenv.maybeGet('FIREBASE_AUTH_DOMAIN') ?? '';
  static String get firebaseProjectId =>
      dotenv.maybeGet('FIREBASE_PROJECT_ID') ?? '';
  static String get firebaseStorageBucket =>
      dotenv.maybeGet('FIREBASE_STORAGE_BUCKET') ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.maybeGet('FIREBASE_MESSAGING_SENDER_ID') ?? '';
  static String get firebaseAppId => dotenv.maybeGet('FIREBASE_APP_ID') ?? '';

  // ===== PayPal (NOTE: do NOT ship secrets in a mobile app) =====
  static String get paypalClientId => dotenv.maybeGet('PAYPAL_CLIENT_ID') ?? '';
  static String get paypalSecret => dotenv.maybeGet('PAYPAL_SECRET') ?? '';
  static String get paypalMode => dotenv.maybeGet('PAYPAL_MODE') ?? 'sandbox';
}
