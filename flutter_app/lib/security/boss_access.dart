import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'role_resolver.dart';

class BossAccess {
  static bool isBoss(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final resolver = context.read<RoleResolver>();
    return resolver.isBoss(email: user.email, uid: user.uid);
  }

  /// Für Boss-only Actions:
  /// await BossAccess.runIfBoss(context, () async { ... });
  static Future<T?> runIfBoss<T>(
      BuildContext context,
      FutureOr<T> Function() action, {
        String deniedMessage = 'Kein Zugriff (Boss-only).',
      }) async {
    if (!isBoss(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deniedMessage)),
      );
      return null;
    }
    return await Future.sync(action);
  }
}
