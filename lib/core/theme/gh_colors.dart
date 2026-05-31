import 'package:flutter/material.dart';

extension GhColorScheme on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get ghPrimary =>
      isDarkMode ? GhColors.darkPrimary : GhColors.primary;
  Color get ghPrimaryLight =>
      isDarkMode ? GhColors.darkPrimaryLight : GhColors.primaryLight;
  Color get ghSurface =>
      isDarkMode ? GhColors.darkSurface : GhColors.surface;
  Color get ghPageBackground =>
      isDarkMode ? GhColors.darkPageBackground : GhColors.pageBackground;
  Color get ghBorder => isDarkMode ? GhColors.darkBorder : GhColors.border;
  Color get ghTextPrimary =>
      isDarkMode ? GhColors.darkTextPrimary : GhColors.textPrimary;
  Color get ghTextSecondary =>
      isDarkMode ? GhColors.darkTextSecondary : GhColors.textSecondary;
  Color get ghTextFaint =>
      isDarkMode ? GhColors.darkTextFaint : GhColors.textFaint;
  Color get ghSuccessLight =>
      isDarkMode ? GhColors.darkSuccessLight : GhColors.successLight;
  Color get ghWarningLight =>
      isDarkMode ? GhColors.darkWarningLight : GhColors.warningLight;
  Color get ghErrorLight =>
      isDarkMode ? GhColors.darkErrorLight : GhColors.errorLight;
}

abstract final class GhColors {
  // ── Light palette ──
  static const primary = Color(0xFF3B5A2A);
  static const primaryHover = Color(0xFF2F4822);
  static const primaryLight = Color(0xFFABCF98);
  static const secondary = Color(0xFF1A107A);
  static const secondaryLight = Color(0xFF877BEE);
  static const surface = Color(0xFFFFFFFF);
  static const pageBackground = Color(0xFFE8EFDD);
  static const border = Color(0xFFE6E6E6);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF525252);
  static const textFaint = Color(0xFFA3A3A3);
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFBBF7D0);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFDE68A);
  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFECACA);

  // ── Dark palette ──
  static const darkPrimary = Color(0xFF6B9F52);
  static const darkPrimaryHover = Color(0xFF7FB466);
  static const darkPrimaryLight = Color(0xFF2D4423);
  static const darkSecondary = Color(0xFF9B8FF0);
  static const darkSecondaryLight = Color(0xFF3A3280);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkPageBackground = Color(0xFF121212);
  static const darkBorder = Color(0xFF3A3A3A);
  static const darkTextPrimary = Color(0xFFE8E8E8);
  static const darkTextSecondary = Color(0xFFB0B0B0);
  static const darkTextFaint = Color(0xFF6B6B6B);
  static const darkSuccessLight = Color(0xFF1A3D28);
  static const darkWarningLight = Color(0xFF3D2E0A);
  static const darkErrorLight = Color(0xFF3D1414);
}
