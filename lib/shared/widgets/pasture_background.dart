import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';

/// Pasture-style backdrop for auth screens. Works even when [splash_background.png] is missing.
class PastureBackground extends StatelessWidget {
  const PastureBackground({super.key, this.child, this.overlayOpacity = 0.55});

  final Widget? child;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF7CB87A),
                Color(0xFF4A8F47),
                Color(0xFF2D6B2A),
              ],
            ),
          ),
        ),
        Image.asset(
          'assets/design/splash_background.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        Container(color: GhColors.primary.withValues(alpha: overlayOpacity)),
        if (child != null) child!,
      ],
    );
  }
}
