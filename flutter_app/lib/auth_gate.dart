// lib/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Wichtig: Dieser Screen heißt bei dir HomeScreen, NICHT MukkeHomeScreen
import 'package:mukke_app/screens/mukke_home_screen.dart'; // enthält class HomeScreen
import 'package:mukke_app/screens/register_screen_.dart';   // passe den Pfad an, falls deine Datei anders heißt

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Nicht eingeloggt -> Registrierung/Anmeldung
        if (snapshot.data == null) {
          return const RegisterScreen(); // Klassenname muss zu deinem Register-Widget passen
        }

        // Eingeloggt -> Home
        return const HomeScreen(); // <- FIX: HomeScreen statt MukkeHomeScreen
      },
    );
  }
}
