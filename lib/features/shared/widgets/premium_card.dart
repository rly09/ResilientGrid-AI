import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
  });

  PremiumCard.feature({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    required int colorIndex,
  })  : backgroundColor = _featureCardColor(colorIndex),
        borderColor = null,
        borderRadius = AppRadius.xl,
        boxShadow = null;

  const PremiumCard.cream({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  })  : backgroundColor = AppColors.surfaceCard,
        borderColor = AppColors.hairline,
        borderRadius = AppRadius.lg,
        boxShadow = null;

  const PremiumCard.productMockup({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  })  : backgroundColor = AppColors.canvas,
        borderColor = AppColors.hairline,
        borderRadius = AppRadius.lg,
        boxShadow = null;

  const PremiumCard.testimonial({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  })  : backgroundColor = AppColors.surfaceCard,
        borderColor = null,
        borderRadius = AppRadius.lg,
        boxShadow = null;

  const PremiumCard.pricing({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    required bool isFeatured,
  })  : backgroundColor = isFeatured ? AppColors.brandTeal : AppColors.canvas,
        borderColor = isFeatured ? null : AppColors.hairline,
        borderRadius = AppRadius.lg,
        boxShadow = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color resolvedBg = backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    Color? resolvedBorderColor = borderColor;

    if (isDark) {
      // In dark mode, map light static backgrounds to dark surfaces
      if (backgroundColor == AppColors.canvas ||
          backgroundColor == AppColors.surfaceCard ||
          backgroundColor == AppColors.surfaceSoft ||
          backgroundColor == AppColors.surfaceStrong) {
        resolvedBg = theme.cardTheme.color ?? theme.colorScheme.surface;
      }
      if (borderColor == AppColors.hairline ||
          borderColor == AppColors.hairlineSoft) {
        resolvedBorderColor = const Color(0xFF2E3E3E);
      }
    } else {
      // In light mode, resolve to corrected canvas color
      if (backgroundColor == AppColors.canvas) {
        resolvedBg = AppColors.canvas;
      }
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        border: resolvedBorderColor != null
            ? Border.all(color: resolvedBorderColor, width: 1)
            : null,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }

  static Color _featureCardColor(int index) {
    return AppColors.featureCardColors[index % AppColors.featureCardColors.length];
  }
}