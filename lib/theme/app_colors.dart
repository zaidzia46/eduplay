import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary brand (purple) ───────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED); // main purple
  static const Color secondary = Color(0xFFF59E0B);
  static const Color tertiary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF9D5FF5); // lighter purple
  static const Color primaryDark = Color(0xFF5B21B6); // darker purple
  static const Color primarySurface = Color(0xFFEDE9FE); // purple tint bg

  // ─── Gradient (header / hero banner) ─────────────────────────────────────
  static const Color gradientStart = Color(0xFF9333EA);
  static const Color gradientEnd = Color(0xFF6D28D9);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Subject colors (matches the screenshot buttons) ─────────────────────
  static const Color english = Color(0xFF7C3AED); // purple
  static const Color maths = Color(0xFF16A34A); // green
  static const Color science = Color(0xFF2563EB); // blue
  static const Color socialStudies = Color(0xFFF59E0B); // amber
  static const Color artAndCraft = Color(0xFFEC4899); // pink
  static const Color generalKnow = Color(0xFF0891B2); // cyan

  // ─── Gamification ────────────────────────────────────────────────────────
  static const Color star = Color(0xFFFBBF24); // gold star
  static const Color streak = Color(0xFFEF4444); // fire red
  static const Color xpGreen = Color(0xFF22C55E); // XP progress
  static const Color badge = Color(0xFFF59E0B); // badge gold

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);

  // ─── Neutral ──────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F3FF); // very light purple tint
  static const Color surface = Color(0xFFFFFFFF); // card background
  static const Color surfaceAlt = Color(0xFFF8F7FF); // alt card bg

  static const Color textPrimary = Color(0xFF1E1B4B); // deep indigo
  static const Color textSecondary = Color(0xFF6B7280); // gray
  static const Color textMuted = Color(0xFF9CA3AF); // light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // text on purple bg

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── Subject surface tints (light bg behind subject cards) ───────────────
  static const Color englishSurface = Color(0xFFEDE9FE);
  static const Color mathsSurface = Color(0xFFDCFCE7);
  static const Color scienceSurface = Color(0xFFDBEAFE);
  static const Color socialStudiesSurface = Color(0xFFFEF3C7);
  static const Color artAndCraftSurface = Color(0xFFFCE7F3);
  static const Color generalKnowSurface = Color(0xFFCFFAFE);
}
