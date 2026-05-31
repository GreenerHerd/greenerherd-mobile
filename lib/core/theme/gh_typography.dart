import 'package:flutter/material.dart';
import 'gh_colors.dart';

abstract final class GhTypography {
  static TextStyle get display => const TextStyle(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get h01 => const TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get h02 => const TextStyle(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get h03 => const TextStyle(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get h04 => const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get h05 => const TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: GhColors.textPrimary,
      );

  static TextStyle get muted => body.copyWith(color: GhColors.textSecondary);

  static TextStyle get stat => const TextStyle(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: GhColors.textPrimary,
      );

  static TextStyle get labelXs => const TextStyle(
        fontSize: 10,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 10,
        color: GhColors.textSecondary,
      );
}
