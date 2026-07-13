import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Reading mode enum used across all reading screens
enum ReadingTheme { light, dark, sepia }

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────
  static ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    scaffold: AppColors.cream,
    surface: AppColors.warmWhite,
    card: AppColors.cardLight,
    primary: AppColors.maroon,
    secondary: AppColors.saffron,
    onPrimary: Colors.white,
    onSurface: AppColors.textDark,
    textPrimary: AppColors.textDark,
    textSecondary: AppColors.textMedium,
    border: AppColors.border,
    divider: AppColors.divider,
    statusBar: SystemUiOverlayStyle.dark,
  );

  // ─────────────────────────────────────────────
  //  DARK THEME
  // ─────────────────────────────────────────────
  static ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    scaffold: AppColors.darkBase,
    surface: AppColors.darkSurface,
    card: AppColors.darkCard,
    primary: AppColors.gold,
    secondary: AppColors.saffron,
    onPrimary: AppColors.darkBase,
    onSurface: Colors.white,
    textPrimary: const Color(0xFFF5E8C8),
    textSecondary: const Color(0xFFD4A96A),
    border: AppColors.borderDark,
    divider: const Color(0xFF3D2020),
    statusBar: SystemUiOverlayStyle.light,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color card,
    required Color primary,
    required Color secondary,
    required Color onPrimary,
    required Color onSurface,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color divider,
    required SystemUiOverlayStyle statusBar,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onPrimary,
        error: AppColors.error,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
      ),
      cardColor: card,
      dividerColor: divider,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: primary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: statusBar,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: 0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1.2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      iconTheme: IconThemeData(color: primary, size: 24),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.7,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}