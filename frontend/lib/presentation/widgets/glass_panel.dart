import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double alpha;
  final Color? glowColor;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.alpha = 0.05,
    this.glowColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          if (glowColor != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: RadialGradient(
                    colors: [
                      glowColor!.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    radius: 1.5,
                  ),
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: alpha),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.0,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
