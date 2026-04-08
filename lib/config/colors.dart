import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D1525);
  static const Color surface = Color(0xFF141E2E);
  static const Color inputBg = Color(0xFF1A2535);
  static const Color biometricBg = Color(0xFF1E2B3D);
  static const Color primary = Color(0xFFD4A520);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8896AB);
  static const Color divider = Color(0xFF2A3547);
  static const Color googleBg = Colors.white;
  static const Color googleText = Color(0xFF1F2937);
  static const Color otpBoxBg = Color(0xFF1A2535);
  static const Color iconColor = Color(0xFF8896AB);
}

// Kept for backward compatibility
class ColorPallete {
  static const Color primaryColor = AppColors.primary;
  static const Color textPrimary = AppColors.textPrimary;
}

extension ColorExt on Color {
  Color setOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
