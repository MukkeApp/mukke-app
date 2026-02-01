// lib/auth_gate.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mukke_app/screens/mukke_home_screen.dart'; // enthält class HomeScreen
import 'package:mukke_app/screens/register_screen_.dart'; // enthält RegisterScreen + AuthFormMode
import 'package:mukke_app/services/boss_access_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Debug-Info (siehst du im Terminal bei flutter run)
        if (kDebugMode) {
          final u = snapshot.data;
          debugPrint('[AuthGate] user=${u?.uid} email=${u?.email}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Auth-Fehler: ${snapshot.error}'),
              ),
            ),
          );
        }

        // Nicht eingeloggt -> immer Login zuerst
        if (snapshot.data == null) {
          return const RegisterScreen(initialMode: AuthFormMode.login);
        }

        // Eingeloggt -> Home (mit Debug-Logout Overlay)
        return Stack(
          children: [
            const HomeScreen(),
            if (kDebugMode) _DebugAuthOverlay(user: snapshot.data!),
          ],
        );
      },
    );
  }
}

class _DebugAuthOverlay extends StatelessWidget {
  final User user;
  const _DebugAuthOverlay({required this.user});

  @override
  Widget build(BuildContext context) {
    final isBoss = BossAccessService().isBoss(user);

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black87,
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'DEBUG: ${isBoss ? "BOSS" : "USER"} • ${user.email ?? user.uid}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text(
                  'Sign out',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
