import 'package:flutter/foundation.dart';
import 'dart:async';
// Optional: Crashlytics einbinden, wenn benötigt
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ErrorHandler {
  static void attach() {
    // Flutter-spezifische Fehler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);

      // Debug-Log
      if (kDebugMode) {
        print('[ErrorHandler] ❗ Flutter Error: ${details.exception}');
        print('[ErrorHandler] 📍 StackTrace: ${details.stack}');
      }

      // Optional: Crashlytics nutzen
      // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Globale Async-Fehler
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        print('[ErrorHandler] ❗ Async Error: $error');
        print('[ErrorHandler] 📍 StackTrace: $stack');
      }

      // Optional: Crashlytics für Async Errors
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

      // true = Fehler wurde behandelt und stoppt die App nicht
      return true;
    };

    // Optional: Uncaught Errors in Futures abfangen
    runZonedGuarded(() {
      // Hier könnte man die App starten oder weitere Listener hinzufügen
    }, (error, stack) {
      if (kDebugMode) {
        print('[ErrorHandler] ❗ Uncaught Zone Error: $error');
        print('[ErrorHandler] 📍 StackTrace: $stack');
      }

      // Optional Crashlytics:
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    });
  }
}
