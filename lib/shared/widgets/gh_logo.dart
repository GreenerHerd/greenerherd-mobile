import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/gh_colors.dart';

/// GreenerHerd mark: one centred circle (avoids double-ring from CircleAvatar + border).
class GhLogo extends StatelessWidget {
  const GhLogo({
    super.key,
    this.size = 88,
    this.showRing = true,
  });

  final double size;
  final bool showRing;

  static const _bullAsset = 'assets/design/logo-bull.png';

  @override
  Widget build(BuildContext context) {
    const ringWidth = 2.0;
    final iconInset = size * 0.22;
    final iconSize = size - iconInset * 2 - (showRing ? ringWidth * 2 : 0);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GhColors.primary,
          border: showRing
              ? Border.all(color: Colors.white, width: ringWidth)
              : null,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(iconInset),
            child: Image.asset(
              _bullAsset,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => SvgPicture.asset(
                'assets/design/species/cattle.svg',
                width: iconSize,
                height: iconSize,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
