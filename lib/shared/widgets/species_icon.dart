import 'package:flutter/material.dart';

import '../../data/models/enums.dart';

/// Species tiles from `assets/design/icons/` (512×512, background baked in).
///
/// - [SpeciesIconVariant.green] — light-green tile; avatars, unselected chips.
/// - [SpeciesIconVariant.white] — white tile; selected species chips on primary fill.
enum SpeciesIconVariant { green, white }

abstract final class SpeciesIcon {
  static String assetPath(Species species, SpeciesIconVariant variant) {
    final key = switch (species) {
      Species.cattle => 'cattle',
      Species.goat => 'goat',
      Species.sheep => 'sheep',
    };
    final tone = variant == SpeciesIconVariant.green ? 'green' : 'white';
    return 'assets/design/icons/${key}_$tone.png';
  }

  static Widget _tile(
    Species species,
    SpeciesIconVariant variant, {
    required double size,
    double radiusFactor = 0.22,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * radiusFactor),
      child: Image.asset(
        assetPath(species, variant),
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  /// Species avatar tile (green background variant by default).
  static Widget avatar(
    Species species, {
    double size = 48,
    bool light = true,
    SpeciesIconVariant variant = SpeciesIconVariant.green,
  }) {
    // Tiles include their own background; `light` kept for API compatibility.
    return _tile(species, variant, size: size);
  }

  static Widget widget(
    Species species, {
    double size = 24,
    SpeciesIconVariant variant = SpeciesIconVariant.green,
  }) {
    return avatar(species, size: size, variant: variant);
  }

  /// Species filter chips: white tile when selected, green tile when not.
  static Widget chipLeading(
    Species species, {
    required bool selected,
    double size = 20,
  }) {
    return _tile(
      species,
      selected ? SpeciesIconVariant.white : SpeciesIconVariant.green,
      size: size,
      radiusFactor: 0.18,
    );
  }

  /// Inline species tile without extra wrapper.
  static Widget glyph(
    Species species, {
    double size = 24,
    SpeciesIconVariant variant = SpeciesIconVariant.green,
  }) {
    return _tile(species, variant, size: size);
  }

  @Deprecated('Use glyph() with SpeciesIconVariant')
  static Widget svg(
    Species species, {
    double size = 24,
    Color? color,
  }) {
    final variant = color == Colors.white
        ? SpeciesIconVariant.white
        : SpeciesIconVariant.green;
    return glyph(species, size: size, variant: variant);
  }
}
