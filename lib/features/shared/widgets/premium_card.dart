import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const PremiumCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.bone,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.tan.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cafeNoir.withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
