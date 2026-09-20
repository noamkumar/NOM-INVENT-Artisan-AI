import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Linen & Olive signature Artisan Card
///
/// Features:
/// - 28.0px rounded radius (Soft Luxury Minimalist)
/// - Pure white surface (Color(0xFFFFFFFF))
/// - Subtle elevation: BoxShadow(color: Color(0x082B2E2A), blurRadius: 40, offset: Offset(0, 12))
/// - Generous default 24px padding
class ArtisanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Border? border;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const ArtisanCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.border,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final effectiveBg = backgroundColor ?? AppColors.cardSurface;

    Widget cardWidget = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: border ?? Border.all(color: AppColors.line, width: 1.0),
        boxShadow: AppElevation.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
