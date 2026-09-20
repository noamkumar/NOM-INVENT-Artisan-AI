import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Artisan AI typography tokens — Soft Luxury Minimalist system
///
/// Features thoughtfully balanced weights (300, 500, 700) with -0.02 letter spacing
/// on structural headers, using bundled Fraunces and Manrope fonts.
class AppTextStyles {
  // --- Font Families ---
  static const _fraunces = 'Fraunces';
  static const _manrope = 'Manrope';

  static List<FontVariation> _displayOpsz(double opsz) =>
      [FontVariation('opsz', opsz)];

  // ---------------------------------------------------------------------------
  // Display & Structural Headers (Letter Spacing -0.02em, Weight 700)
  // ---------------------------------------------------------------------------
  static TextStyle displayLarge = TextStyle(
    fontFamily: _fraunces,
    fontVariations: _displayOpsz(9),
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 36,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: _fraunces,
    fontVariations: _displayOpsz(9),
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 28,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: _fraunces,
    fontVariations: _displayOpsz(9),
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 24,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineLarge = TextStyle(
    fontFamily: _fraunces,
    fontVariations: _displayOpsz(36),
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 22,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: _fraunces,
    fontVariations: _displayOpsz(36),
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 20,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: _fraunces,
    fontVariations: _displayOpsz(36),
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 18,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Subheadings & Medium Body (Weight 500)
  // ---------------------------------------------------------------------------
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _manrope,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ---------------------------------------------------------------------------
  // Body Text (Weights 400 & 500)
  // ---------------------------------------------------------------------------
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _manrope,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _manrope,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Labels, Capsules & Buttons (Weight 700 & 500)
  // ---------------------------------------------------------------------------
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _manrope,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _manrope,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _manrope,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  // ---------------------------------------------------------------------------
  // Airy Metadata & Captions (Weight 300)
  // ---------------------------------------------------------------------------
  static const TextStyle caption = TextStyle(
    fontFamily: _manrope,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _manrope,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  AppTextStyles._();
}