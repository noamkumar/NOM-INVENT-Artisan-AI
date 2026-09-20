import 'package:flutter/material.dart';

/// Artisan AI — Soft Luxury Minimalist (Linen & Olive) design-token palette.
///
/// Palette foundation:
///   - App background: Color(0xFFFAF6F0) — Warm Travertine Off-White
///   - Card/surface:   Color(0xFFFFFFFF) — Pure White
///   - Main text:      Color(0xFF2B2E2A) — Deep Espresso Charcoal
///   - Primary accent: Color(0xFF606C56) — Muted Sage Green
class AppColors {
  // ---------------------------------------------------------------------------
  // Core Soft Luxury Minimalist (Linen & Olive) Palette
  // ---------------------------------------------------------------------------

  /// Primary accent: Muted Sage Green
  static const sage           = Color(0xFF606C56);
  static const sageDark       = Color(0xFF454E3E);
  static const sageLight      = Color(0xFFE8ECE4);

  /// Secondary accent: Warm Ochre / Linen Sand
  static const linenSand      = Color(0xFFC7A379);
  static const linenSandDark  = Color(0xFFA6845B);
  static const linenSandLight = Color(0xFFF6EFE6);

  /// Subtle accent: Olive Earth
  static const olive          = Color(0xFF7D876E);
  static const oliveLight     = Color(0xFFEFF3EA);
  static const oliveDark      = Color(0xFF5A634E);

  /// Success / Confirmed / Active
  static const success        = Color(0xFF4A6B4E);
  static const successLight   = Color(0xFFE3EFE5);

  // ---------------------------------------------------------------------------
  // Ink Typography: Deep Espresso Charcoal
  // ---------------------------------------------------------------------------
  static const espresso       = Color(0xFF2B2E2A); // Main text
  static const espressoSoft   = Color(0xFF6A6E67); // Secondary text
  static const espressoFaint  = Color(0xFFA2A79F); // Tertiary text / hints

  // ---------------------------------------------------------------------------
  // Surfaces & Backgrounds
  // ---------------------------------------------------------------------------
  static const travertine     = Color(0xFFFAF6F0); // Page background
  static const cardSurface    = Color(0xFFFFFFFF); // Card background
  static const linenMuted     = Color(0xFFF2ECE1); // Capsule tracks / chips

  // ---------------------------------------------------------------------------
  // Structural & Shadows
  // ---------------------------------------------------------------------------
  static const line           = Color(0x142B2E2A); // 8% opacity line
  static const border         = Color(0x242B2E2A); // 14% subtle border
  static const shadowColor    = Color(0x082B2E2A); // Subtle luxury shadow
  static const shadowLifted   = Color(0x142B2E2A);

  // ---------------------------------------------------------------------------
  // Semantic Aliases mapped to Linen & Olive Palette
  // ---------------------------------------------------------------------------
  static const primary        = sage;
  static const primaryDark    = sageDark;
  static const primaryLight   = sageLight;

  static const secondary      = linenSand;
  static const secondaryDark  = linenSandDark;
  static const secondaryLight = linenSandLight;

  static const textPrimary    = espresso;
  static const textSecondary  = espressoSoft;
  static const textTertiary   = espressoFaint;
  static const textOnPrimary  = Color(0xFFFFFFFF);

  static const background     = travertine;
  static const surface        = cardSurface;
  static const surfaceVariant = linenMuted;

  static const error          = Color(0xFFBA4A3A);
  static const warning        = Color(0xFFD48B38);
  static const divider        = line;
  static const dottedBorder   = border;
  static const shadow         = shadowColor;

  // ---------------------------------------------------------------------------
  // Backward-compatible color roles mapped seamlessly to Linen & Olive
  // ---------------------------------------------------------------------------
  static const terracotta     = sage;          // Primary buttons map to Sage
  static const terracottaDark = sageDark;
  static const terracottaLight= sageLight;

  static const gold           = linenSand;     // Secondary buttons map to Linen Sand
  static const goldDark       = linenSandDark;
  static const goldLight      = linenSandLight;

  static const berry          = olive;
  static const berryDark      = oliveDark;
  static const berryLight     = oliveLight;

  static const blueAccent     = Color(0xFF4A6572);
  static const blueAccentDark = Color(0xFF344955);
  static const blueAccentLight= Color(0xFFE2E9EC);

  static const parchment      = travertine;
  static const parchmentDeep  = linenMuted;
  static const ink            = espresso;
  static const inkSoft        = espressoSoft;
  static const inkFaint       = espressoFaint;

  static const statusActionBg = sageLight;
  static const statusActionFg = sageDark;
  static const statusPendingBg= linenSandLight;
  static const statusPendingFg= linenSandDark;
  static const statusSuccessBg= successLight;
  static const statusSuccessFg= success;

  static const online         = success;
  static const syncing        = linenSand;
  static const offline        = espressoSoft;

  static const statusLive     = success;
  static const statusPending  = linenSand;
  static const statusDraft    = espressoSoft;
  static const statusSold     = linenSand;

  static const charcoal       = espresso;
  static const charcoalSoft   = espressoSoft;
  static const cream          = cardSurface;
  static const oak            = border;
  static const mustard        = linenSand;
  static const brick          = sageDark;
  static const aboveRange     = olive;
  static const info           = blueAccent;
  static const forestGreen    = success;
  static const forestGreenDark= oliveDark;
  static const overlay        = Color(0x662B2E2A);

  AppColors._();
}