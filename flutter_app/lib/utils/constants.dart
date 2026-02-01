import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF111111); // Hauptfarbe Mukke
  static const Color accent = Color(0xFFFFC300); // Gelb für Highlights
  static const Color background = Color(0xFFF5F5F5); // Hintergrund hell
  static const Color error = Color(0xFFB00020); // Fehlerfarbe
  static const Color success = Color(0xFF00C853); // Erfolgsfarbe
  static const Color text = Color(0xFF333333); // Standard-Textfarbe
  static const Color surfaceDark = Color(0xFF1C1C1E); // Dunkler Hintergrund
}

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.text,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 32.0;
}

class AppIcons {
  static const IconData heart = Icons.favorite;
  static const IconData profile = Icons.person;
  static const IconData music = Icons.music_note;
  static const IconData game = Icons.sports_esports;
  static const IconData live = Icons.videocam;
  static const IconData fashion = Icons.shopping_bag;
  static const IconData settings = Icons.settings;
}
