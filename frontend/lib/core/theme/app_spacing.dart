import 'package:flutter/material.dart';

/// Responsive spacing system — 8pt grid tailored for Linen & Olive luxury minimalist
class AppSpacing {
  // Base spacing units
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;

  // Semantic spacing: Soft Luxury Linen & Olive specs
  static const double screenPadding  = 20.0;
  static const double cardPadding    = 24.0; // Generous 24px card padding
  static const double sectionSpacing = 32.0; // Generous 32px section spacing
  static const double itemSpacing    = 16.0;

  // Touch targets — 48dp minimum per WCAG
  static const double minTouchTarget        = 48.0;
  static const double minTouchTargetCompact = 40.0;

  // Icon sizes
  static const double iconSize       = 24.0;
  static const double iconSizeLarge  = 32.0;
  static const double iconSizeSmall  = 20.0;
  static const double iconSizeXLarge = 48.0;

  // Responsive screen padding
  static double getScreenPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 16.0;
    if (w < 480) return 20.0;
    if (w < 600) return 24.0;
    if (w < 900) return 32.0;
    return 48.0;
  }

  // Responsive font-size scale
  static double getResponsiveFontScale(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 0.88;
    if (w < 480) return 0.95;
    if (w < 600) return 1.0;
    if (w < 900) return 1.08;
    return 1.15;
  }

  // Responsive button height
  static double getButtonHeight(BuildContext context, {bool compact = false}) {
    final w = MediaQuery.of(context).size.width;
    if (compact) return w < 480 ? 38.0 : minTouchTargetCompact;
    return w < 480 ? 46.0 : minTouchTarget;
  }

  // Responsive list gap
  static double getListGap(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 480) return 12.0;
    if (w < 600) return 16.0;
    if (w < 900) return 24.0;
    return 32.0;
  }

  AppSpacing._();
}

/// Rounded corners: Linen & Olive architecture (28.0 main card radius)
class AppRadii {
  static const double xs          = 6.0;
  static const double sm          = 10.0;
  static const double md          = 16.0;
  static const double lg          = 20.0;
  static const double xl          = 24.0;
  static const double xxl         = 28.0;
  static const double full        = 999.0;

  // Semantic radii
  static const double button      = 999.0; // Fully rounded capsule buttons
  static const double card        = 28.0;  // 28px main card radius
  static const double chip        = 999.0; // Capsule chips
  static const double bottomSheet = 32.0;
  static const double dialog      = 28.0;
  static const double inputField  = 16.0;

  // Responsive card radius
  static double getCardRadius(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 20.0;
    if (w < 600) return 28.0;
    return 32.0;
  }

  AppRadii._();
}

/// Elevation and subtle luxury shadow definitions
class AppElevation {
  static const double none    = 0;
  static const double subtle  = 1;
  static const double low     = 2;
  static const double medium  = 4;
  static const double high    = 8;
  static const double highest = 16;

  /// Linen & Olive signature subtle luxury shadow: BoxShadow(color: Color(0x082B2E2A), blurRadius: 40, offset: Offset(0, 12))
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x082B2E2A),
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  /// Lifted shadow for modal sheets and floating actions
  static const List<BoxShadow> cardShadowLifted = [
    BoxShadow(
      color: Color(0x142B2E2A),
      blurRadius: 48,
      spreadRadius: -4,
      offset: Offset(0, 16),
    ),
  ];

  static List<BoxShadow> getCardShadow(BuildContext context) => cardShadow;

  AppElevation._();
}