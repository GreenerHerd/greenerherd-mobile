import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import 'gh_design_icons.dart';

/// Renders a square design-handoff illustration (e.g. welfare, bottle).
class GhDesignIcon extends StatelessWidget {
  const GhDesignIcon({
    super.key,
    required this.assetPath,
    this.size = 28,
    this.opacity = 1,
  });

  final String assetPath;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Tappable status chip with a design icon (group wizard member row, filters).
class GhDesignStatusButton extends StatelessWidget {
  const GhDesignStatusButton({
    super.key,
    required this.assetPath,
    required this.active,
    required this.tooltip,
    required this.onTap,
    this.size = 36,
    this.iconVisualScale = 1,
    this.enabled = true,
  });

  final String assetPath;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  /// Scales artwork inside the chip (e.g. medication PNG has less padding).
  final double iconVisualScale;

  /// When false, the chip is non-interactive and visually muted.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final chipOpacity = !enabled ? 0.28 : (active ? 1.0 : 0.5);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: !enabled
                ? GhColors.primaryLight.withValues(alpha: 0.2)
                : active
                    ? GhColors.primaryLight
                    : GhColors.primaryLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: !enabled
                  ? GhColors.border
                  : active
                      ? GhColors.primary
                      : GhColors.border,
              width: active && enabled ? 1.5 : 1,
            ),
          ),
          child: Opacity(
            opacity: chipOpacity,
            child: Padding(
              padding: EdgeInsets.all(size * 0.16),
              child: Center(
                child: SizedBox(
                  width: size * 0.68 * iconVisualScale,
                  height: size * 0.68 * iconVisualScale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(assetPath),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Leading icon for list tiles and menus.
class GhDesignListIcon extends StatelessWidget {
  const GhDesignListIcon({
    super.key,
    required this.assetPath,
    this.size = 32,
  });

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: GhDesignIcon(assetPath: assetPath, size: size),
    );
  }
}

class GhVideoLessonsIcon extends StatelessWidget {
  const GhVideoLessonsIcon({super.key, this.size = 28, this.opacity = 1});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return GhDesignIcon(
      assetPath: GhDesignIcons.videoLessons,
      size: size,
      opacity: opacity,
    );
  }
}

class GhAnimalDeathIcon extends StatelessWidget {
  const GhAnimalDeathIcon({super.key, this.size = 28, this.opacity = 1});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return GhDesignIcon(
      assetPath: GhDesignIcons.animalDeath,
      size: size,
      opacity: opacity,
    );
  }
}
