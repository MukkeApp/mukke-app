import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_gate.dart';
import '../security/role_resolver.dart';

class BossGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const BossGuard({
    super.key,
    required this.child,
    this.fallback,
  });

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

        final user = snapshot.data;
        if (user == null) return const AuthGate();

        final resolver = context.read<RoleResolver>();
        final isBoss = resolver.isBoss(email: user.email, uid: user.uid);

        if (isBoss) return child;
        return fallback ?? const _DefaultDenied();
      },
    );
  }
}

class _DefaultDenied extends StatelessWidget {
  const _DefaultDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kein Zugriff')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Dieser Bereich ist Boss-only.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Zurück'),
            ),
          ],
        ),
      ),
    );
  }
}
