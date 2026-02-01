import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BossPanelScreen extends StatelessWidget {
  const BossPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boss Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Boss-only Bereich',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Eingeloggt als: ${user?.email ?? user?.uid ?? "-"}'),
            const SizedBox(height: 24),

            // Platzhalter für kommende Boss Features:
            const Text('Coming next:'),
            const SizedBox(height: 8),
            const Text('• Server Status (Ping)'),
            const Text('• Jarviz Logs (Boss-only)'),
            const Text('• Feature Flags'),
          ],
        ),
      ),
    );
  }
}
