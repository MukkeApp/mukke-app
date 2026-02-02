import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../security/role_resolver.dart';

class BossOnly extends StatelessWidget {
  final Widget child;
  final Widget? orElse;

  const BossOnly({
    super.key,
    required this.child,
    this.orElse,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return orElse ?? const SizedBox.shrink();

    final resolver = context.watch<RoleResolver>();
    final isBoss = resolver.isBoss(email: user.email, uid: user.uid);

    return isBoss ? child : (orElse ?? const SizedBox.shrink());
  }
}
