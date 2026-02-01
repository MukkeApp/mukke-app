// Basic Flutter widget test for MukkeApp.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Richtiger Paketname & Datei:
import 'package:mukke_app/main.dart';

void main() {
  testWidgets('App builds without exceptions', (WidgetTester tester) async {
    // Root-Widget deiner App (aus main.dart):
    await tester.pumpWidget(const MukkeApp());

    // Erwartung: Es existiert genau ein MaterialApp im Widget-Baum.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
