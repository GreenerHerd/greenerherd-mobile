import 'package:flutter/material.dart';
import 'gh_colors.dart';
import 'gh_typography.dart';

abstract final class GhTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: GhColors.pageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GhColors.primary,
        brightness: Brightness.light,
        primary: GhColors.primary,
        surface: GhColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GhColors.surface,
        foregroundColor: GhColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: GhColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GhColors.primary,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: GhTypography.h01,
        headlineMedium: GhTypography.h02,
        titleMedium: GhTypography.h03,
        bodyMedium: GhTypography.body,
        labelSmall: GhTypography.h05,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: GhColors.darkPageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GhColors.darkPrimary,
        brightness: Brightness.dark,
        primary: GhColors.darkPrimary,
        surface: GhColors.darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: GhColors.darkSurface,
        foregroundColor: GhColors.darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: GhColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GhColors.darkPrimary,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: GhColors.darkBorder,
      ),
      textTheme: TextTheme(
        headlineLarge: GhTypography.h01.copyWith(color: GhColors.darkTextPrimary),
        headlineMedium: GhTypography.h02.copyWith(color: GhColors.darkTextPrimary),
        titleMedium: GhTypography.h03.copyWith(color: GhColors.darkTextPrimary),
        bodyMedium: GhTypography.body.copyWith(color: GhColors.darkTextPrimary),
        labelSmall: GhTypography.h05.copyWith(color: GhColors.darkTextPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: GhColors.darkSurface,
        hintStyle: const TextStyle(color: GhColors.darkTextFaint),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: GhColors.darkBorder),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GhColors.darkSurface,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: GhColors.darkSurface,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: GhColors.darkSurface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GhColors.darkPrimary;
          }
          return GhColors.darkTextFaint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GhColors.darkPrimaryLight;
          }
          return GhColors.darkBorder;
        }),
      ),
    );
  }
}
