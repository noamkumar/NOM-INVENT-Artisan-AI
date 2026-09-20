import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Centralized ThemeData for Artisan AI — Soft Luxury Minimalist (Linen & Olive)
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme — Soft Luxury Linen & Olive
      colorScheme: const ColorScheme.light(
        primary:            AppColors.sage,
        onPrimary:          AppColors.textOnPrimary,
        primaryContainer:   AppColors.sageLight,
        onPrimaryContainer: AppColors.sageDark,

        secondary:            AppColors.linenSand,
        onSecondary:          AppColors.textOnPrimary,
        secondaryContainer:   AppColors.linenSandLight,
        onSecondaryContainer: AppColors.linenSandDark,

        tertiary:             AppColors.olive,
        onTertiary:           AppColors.textOnPrimary,
        tertiaryContainer:    AppColors.oliveLight,
        onTertiaryContainer:  AppColors.oliveDark,

        error:    AppColors.error,
        onError:  AppColors.textOnPrimary,

        surface:                   AppColors.cardSurface,
        onSurface:                 AppColors.textPrimary,
        surfaceContainerHighest:   AppColors.linenMuted,

        outline:        AppColors.border,
        outlineVariant: AppColors.line,
        shadow:         AppColors.shadowColor,
      ),

      scaffoldBackgroundColor: AppColors.travertine,

      // Typography — Fraunces + Manrope
      textTheme: TextTheme(
        displayLarge:   AppTextStyles.displayLarge,
        displayMedium:  AppTextStyles.displayMedium,
        displaySmall:   AppTextStyles.displaySmall,
        headlineLarge:  AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall:  AppTextStyles.headlineSmall,
        titleMedium:    AppTextStyles.titleMedium,
        titleSmall:     AppTextStyles.titleSmall,
        bodyLarge:      AppTextStyles.bodyLarge,
        bodyMedium:     AppTextStyles.bodyMedium,
        bodySmall:      AppTextStyles.bodySmall,
        labelLarge:     AppTextStyles.labelLarge,
        labelMedium:    AppTextStyles.labelMedium,
        labelSmall:     AppTextStyles.labelSmall,
      ),

      // AppBar — clean travertine background, subtle espresso typography
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.travertine,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMedium,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconSize,
        ),
      ),

      // Card — 28px radius, pure white surface, subtle luxury shadow
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.line, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
      ),

      // Elevated Button — primary action: Muted Sage Green capsule
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Outlined Button — card surface bg, subtle border, espresso text — capsule
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.cardSurface,
          foregroundColor: AppColors.espresso,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // Text Button — sage link style
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sage,
          minimumSize: const Size(0, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: AppTextStyles.labelMedium,
        ),
      ),

      // Input Decoration — card surface, subtle border, sage focus ring
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inputField),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inputField),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inputField),
          borderSide: const BorderSide(color: AppColors.sage, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inputField),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inputField),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // Chip — capsule shape; selected = sage fill
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.linenMuted,
        selectedColor: AppColors.sage,
        disabledColor: AppColors.linenMuted,
        labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
          side: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        elevation: 0,
        pressElevation: 0,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardSurface,
        selectedItemColor: AppColors.sage,
        unselectedItemColor: AppColors.espressoFaint,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppElevation.subtle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
        ),
        titleTextStyle: AppTextStyles.headlineMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardSurface,
        modalBackgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.bottomSheet),
          ),
        ),
        modalElevation: 0,
        shadowColor: AppColors.shadowLifted,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.espresso,
        contentTextStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sage,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
    );
  }
}