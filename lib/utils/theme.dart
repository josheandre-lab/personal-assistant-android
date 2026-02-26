import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Renk paleti
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFEADDFF);
  static const Color onPrimaryContainerLight = Color(0xFF21005D);
  
  static const Color secondaryLight = Color(0xFF625B71);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFE8DEF8);
  static const Color onSecondaryContainerLight = Color(0xFF1D192B);
  
  static const Color tertiaryLight = Color(0xFF7D5260);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFFFFD8E4);
  static const Color onTertiaryContainerLight = Color(0xFF31111D);
  
  static const Color errorLight = Color(0xFFB3261E);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFF9DEDC);
  static const Color onErrorContainerLight = Color(0xFF410E0B);
  
  static const Color surfaceLight = Color(0xFFFFFBFE);
  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color surfaceVariantLight = Color(0xFFE7E0EC);
  static const Color onSurfaceVariantLight = Color(0xFF49454F);
  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineVariantLight = Color(0xFFCAC4D0);
  
  static const Color primaryDark = Color(0xFFD0BCFF);
  static const Color onPrimaryDark = Color(0xFF381E72);
  static const Color primaryContainerDark = Color(0xFF4F378B);
  static const Color onPrimaryContainerDark = Color(0xFFEADDFF);
  
  static const Color secondaryDark = Color(0xFFCCC2DC);
  static const Color onSecondaryDark = Color(0xFF332D41);
  static const Color secondaryContainerDark = Color(0xFF4A4458);
  static const Color onSecondaryContainerDark = Color(0xFFE8DEF8);
  
  static const Color tertiaryDark = Color(0xFFEFB8C8);
  static const Color onTertiaryDark = Color(0xFF492532);
  static const Color tertiaryContainerDark = Color(0xFF633B48);
  static const Color onTertiaryContainerDark = Color(0xFFFFD8E4);
  
  static const Color errorDark = Color(0xFFF2B8B5);
  static const Color onErrorDark = Color(0xFF601410);
  static const Color errorContainerDark = Color(0xFF8C1D18);
  static const Color onErrorContainerDark = Color(0xFFF9DEDC);
  
  static const Color surfaceDark = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);
  static const Color surfaceVariantDark = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);
  static const Color outlineDark = Color(0xFF938F99);
  static const Color outlineVariantDark = Color(0xFF49454F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryLight,
        onPrimary: onPrimaryLight,
        primaryContainer: primaryContainerLight,
        onPrimaryContainer: onPrimaryContainerLight,
        secondary: secondaryLight,
        onSecondary: onSecondaryLight,
        secondaryContainer: secondaryContainerLight,
        onSecondaryContainer: onSecondaryContainerLight,
        tertiary: tertiaryLight,
        onTertiary: onTertiaryLight,
        tertiaryContainer: tertiaryContainerLight,
        onTertiaryContainer: onTertiaryContainerLight,
        error: errorLight,
        onError: onErrorLight,
        errorContainer: errorContainerLight,
        onErrorContainer: onErrorContainerLight,
        surface: surfaceLight,
        onSurface: onSurfaceLight,
        surfaceContainerHighest: surfaceVariantLight,
        onSurfaceVariant: onSurfaceVariantLight,
        outline: outlineLight,
        outlineVariant: outlineVariantLight,
      ),
      textTheme: _textTheme(Brightness.light),
      appBarTheme: _appBarTheme(Brightness.light),
      cardTheme: _cardTheme,
      floatingActionButtonTheme: _fabTheme,
      bottomNavigationBarTheme: _bottomNavTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      chipTheme: _chipTheme(Brightness.light),
      dividerTheme: _dividerTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryDark,
        onPrimary: onPrimaryDark,
        primaryContainer: primaryContainerDark,
        onPrimaryContainer: onPrimaryContainerDark,
        secondary: secondaryDark,
        onSecondary: onSecondaryDark,
        secondaryContainer: secondaryContainerDark,
        onSecondaryContainer: onSecondaryContainerDark,
        tertiary: tertiaryDark,
        onTertiary: onTertiaryDark,
        tertiaryContainer: tertiaryContainerDark,
        onTertiaryContainer: onTertiaryContainerDark,
        error: errorDark,
        onError: onErrorDark,
        errorContainer: errorContainerDark,
        onErrorContainer: onErrorContainerDark,
        surface: surfaceDark,
        onSurface: onSurfaceDark,
        surfaceContainerHighest: surfaceVariantDark,
        onSurfaceVariant: onSurfaceVariantDark,
        outline: outlineDark,
        outlineVariant: outlineVariantDark,
      ),
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: _appBarTheme(Brightness.dark),
      cardTheme: _cardTheme,
      floatingActionButtonTheme: _fabTheme,
      bottomNavigationBarTheme: _bottomNavTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      chipTheme: _chipTheme(Brightness.dark),
      dividerTheme: _dividerTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final color = isDark ? onSurfaceDark : onSurfaceLight;
    
    return TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: color,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: color,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: color,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: color,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: color,
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: color,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: color,
      ),
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 3,
      centerTitle: true,
      backgroundColor: isDark ? surfaceDark : surfaceLight,
      foregroundColor: isDark ? onSurfaceDark : onSurfaceLight,
    );
  }

  static const CardTheme _cardTheme = CardTheme(
    elevation: 1,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );

  static const FloatingActionButtonThemeData _fabTheme = 
      FloatingActionButtonThemeData(
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  static BottomNavigationBarThemeData _bottomNavTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? surfaceDark : surfaceLight,
      selectedItemColor: isDark ? primaryDark : primaryLight,
      unselectedItemColor: isDark ? outlineDark : outlineLight,
      type: BottomNavigationBarType.fixed,
      elevation: 3,
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? surfaceVariantDark : surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? primaryDark : primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? errorDark : errorLight,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ChipThemeData _chipTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ChipThemeData(
      backgroundColor: isDark ? surfaceVariantDark : surfaceVariantLight,
      selectedColor: isDark ? primaryContainerDark : primaryContainerLight,
      labelStyle: TextStyle(
        color: isDark ? onSurfaceVariantDark : onSurfaceVariantLight,
      ),
      secondaryLabelStyle: TextStyle(
        color: isDark ? onPrimaryContainerDark : onPrimaryContainerLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static const DividerThemeData _dividerTheme = DividerThemeData(
    space: 1,
    thickness: 1,
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );
}
