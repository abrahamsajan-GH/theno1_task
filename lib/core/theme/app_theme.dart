import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            secondary: const Color(0xFFF43F5E),
            surface: Colors.white,
            error: const Color(0xFFE11D48),
          ).copyWith(
            surfaceContainer: Colors.white,
            surfaceContainerLow: Colors.white,
            surfaceContainerLowest: Colors.white,
            surfaceContainerHigh: Colors.white,
            surfaceContainerHighest: Colors.white,
            primaryContainer: Colors.white,
            secondaryContainer: Colors.white,
            tertiaryContainer: Colors.white,
            errorContainer: Colors.white,
            surfaceTint: Colors.transparent,
          ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 217, 223, 230),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(letterSpacing: -1.0),
        titleLarge: baseTextTheme.titleLarge?.copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: const Color(0xFF0F172A),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: const Color(0x0C000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFF4F46E5),
        unselectedItemColor: Color(0xFF94A3B8),
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
      datePickerTheme: const DatePickerThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.white),
    );
  }
}
