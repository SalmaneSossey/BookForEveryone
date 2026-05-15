import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // New Design System Palette
  static const Color bg = Color(0xFFF6F2EB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1B1A17);
  static const Color ink2 = Color(0xFF3A352E);
  static const Color muted = Color(0xFF827B6F);
  static const Color faint = Color(0xFFB6AE9F);
  static const Color hair = Color(0xFFE8E1D5);
  static const Color pill = Color(0xFFEDE6D8);
  static const Color accent = Color(0xFFB8552D);
  static const Color accentSoft = Color(0xFFF1E2D6);
  static const Color dark = Color(0xFF1B1A17);

  // Fallbacks for existing references to avoid breaking the build immediately
  static const Color surface = bg;
  static const Color teal = accent;
  static const Color coral = accent;
  static const Color amber = accent;
  static const Color violet = accent;
  static const Color blue = accent;
  static const Color green = accent;
}
