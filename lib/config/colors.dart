import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds ──────────────────────────────────────────
  static const Color background = Color.fromARGB(255, 0, 0, 0);
  static const Color surface = Color(0xFF0E1A10);
  static const Color inputBg = Color(0xFF111D13);
  static const Color biometricBg = Color(0xFF152017);

  // ── Primary Accent ────────────────────────────────────────
  static const Color primary = Color(0xFF3DFF6B);
  static const Color primaryGlow = Color(0x333DFF6B);

  // ── Scout / Map Markers ───────────────────────────────────
  // Orange dot = current scout position
  static const Color scoutMarker = Color(0xFFF5A020);
  static const Color missionMarker = Color(0xFF3DFF6B);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF6B7A6D);
  static const Color textAccent = Color(0xFF3DFF6B);

  // ── Chrome ────────────────────────────────────────────────
  static const Color divider = Color(0xFF1A2B1C);
  static const Color iconColor = Color(0xFF6B7A6D);
  static const Color otpBoxBg = Color(0xFF111D13);

  // ── Google / OAuth ────────────────────────────────────────
  static const Color googleBg = Colors.white;
  static const Color googleText = Color(0xFF1F2937);

  // ── Map Grid ──────────────────────────────────────────────
  static const Color mapGrid = Color(0xFF0D1A0F);
}

extension ColorExt on Color {
  Color setOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
