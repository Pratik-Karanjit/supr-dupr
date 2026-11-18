import 'package:flutter/material.dart';

class AppTheme {
  // SUPR DUPR Premium Athletic Color Palette
  static const Color navyHero = Color(0xFF0A1428);
  static const Color navyHeroLight = Color(0xFF122347);
  static const Color navyCard = Color(0xFF0F1C36);
  static const Color navyBorder = Color(0xFF1E2E4E);
  static const Color offWhiteCanvas = Color(0xFFF8FAFC);
  static const Color pureWhiteCard = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  
  // Accents & Ratings
  static const Color brightCyan = Color(0xFF00B0FF);
  
  // Typography
  static const Color textSlate = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLightMuted = Color(0xFF94A3B8);
  
  // Status Colors
  static const Color emeraldWin = Color(0xFF10B981);
  static const Color coralLoss = Color(0xFFEF4444);
  static const Color warningAmber = Color(0xFFF59E0B);

  static ThemeData get suprDuprTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhiteCanvas,
      colorScheme: const ColorScheme.light(
        primary: navyHero,
        onPrimary: Colors.white,
        secondary: brightCyan,
        onSecondary: textSlate,
        surface: pureWhiteCard,
        onSurface: textSlate,
        error: coralLoss,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navyHero,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: pureWhiteCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyHero,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: const Color.fromRGBO(10, 20, 40, 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: navyBorder),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navyHero,
          side: const BorderSide(color: borderSubtle, width: 1.5),
          backgroundColor: pureWhiteCard,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: pureWhiteCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navyHero, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textLightMuted, fontSize: 13),
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: navyHero.withOpacity(0.08),
        elevation: 3,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: navyHero,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: navyHero);
          }
          return const IconThemeData(color: textMuted);
        }),
      ),
    );
  }
}
