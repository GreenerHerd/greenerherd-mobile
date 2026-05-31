import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import '../io/local_image.dart';
import '../../data/models/models.dart';
import 'species_icon.dart';

class AnimalAvatar extends StatelessWidget {
  const AnimalAvatar({
    super.key,
    required this.animal,
    this.size = 48,
    this.onTap,
    this.showCameraBadge = false,
  });

  final Animal animal;
  final double size;
  final VoidCallback? onTap;
  final bool showCameraBadge;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.22);

    Widget content;
    final path = animal.photoPath;
    if (path != null && path.isNotEmpty && localFileExists(path)) {
      content = ClipRRect(
        borderRadius: radius,
        child: buildLocalFileImage(
          path: path,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _speciesFallback(),
        ),
      );
    } else {
      content = _speciesFallback();
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: GhColors.border),
      ),
      child: content,
    );

    if (!showCameraBadge && onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (showCameraBadge)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  color: GhColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: GhColors.surface, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: size * 0.18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _speciesFallback() => SpeciesIcon.avatar(animal.species, size: size);
}
