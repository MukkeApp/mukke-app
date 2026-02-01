import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mukke_app/services/boss_access_service.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    final isBoss = BossAccessService().isBoss(user);

    if (isBoss) return child;

    return fallback ??
        const Center(
          child: Text('Kein Zugriff.'),
        );
  }
}
