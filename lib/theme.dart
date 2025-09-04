import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BRColors {
  // Calming light theme colors
  static const background = Color(0xFFFAFBFF);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  
  static const primary = Color(0xFF6366F1); // indigo-500
  static const primaryHover = Color(0xFF4F46E5);
  static const primaryGradientStart = Color(0xFFA5B4FC);
  static const primaryGradientEnd = Color(0xFF6366F1);
  
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  
  static const text = Color(0xFF0F172A); // 90% opacity
  static const textSecondary = Color(0xFF334155); // 70% opacity
  
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFE2E8F0);
}

class BRSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

class BRRadius {
  static const double standard = 16.0;
  static const double large = 20.0;
  static const double chip = 24.0;
  static const double full = 999.0;
}

class BRTypography {
  // H1 28/700, H2 22/700, Title 18/600, Body 16/400, Caption 13/400
  static const double h1Size = 28.0;
  static const double h2Size = 22.0;
  static const double titleSize = 18.0;
  static const double bodySize = 16.0;
  static const double captionSize = 13.0;
  
  static const FontWeight h1Weight = FontWeight.w700;
  static const FontWeight h2Weight = FontWeight.w700;
  static const FontWeight titleWeight = FontWeight.w600;
  static const FontWeight bodyWeight = FontWeight.w400;
  static const FontWeight captionWeight = FontWeight.w400;
}

class BRShadows {
  // Soft shadow with blur 20, y=6, 8% opacity
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
}

ThemeData get calmingLightTheme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: BRColors.primary,
    primaryContainer: BRColors.primaryGradientStart,
    secondary: BRColors.primary,
    surface: BRColors.surface,
    surfaceContainerHighest: BRColors.card,
    onSurface: BRColors.text,
    onSurfaceVariant: BRColors.textSecondary,
    outline: BRColors.border,
    error: BRColors.error,
  ),
  scaffoldBackgroundColor: BRColors.background,
  
  // App Bar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: BRColors.background,
    foregroundColor: BRColors.text,
    elevation: 0,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.inter(
      fontSize: BRTypography.h2Size,
      fontWeight: BRTypography.h2Weight,
      color: BRColors.text,
    ),
  ),
  
  // Card Theme with soft shadows
  cardTheme: CardThemeData(
    color: BRColors.card,
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BRRadius.standard),
    ),
    margin: EdgeInsets.zero,
  ),
  
  // Text Theme with Inter font
  textTheme: TextTheme(
    // H1 28/700
    displaySmall: GoogleFonts.inter(
      fontSize: BRTypography.h1Size,
      fontWeight: BRTypography.h1Weight,
      color: BRColors.text,
      height: 1.2,
    ),
    // H2 22/700
    headlineSmall: GoogleFonts.inter(
      fontSize: BRTypography.h2Size,
      fontWeight: BRTypography.h2Weight,
      color: BRColors.text,
      height: 1.3,
    ),
    // Title 18/600
    titleLarge: GoogleFonts.inter(
      fontSize: BRTypography.titleSize,
      fontWeight: BRTypography.titleWeight,
      color: BRColors.text,
      height: 1.4,
    ),
    // Body 16/400
    bodyLarge: GoogleFonts.inter(
      fontSize: BRTypography.bodySize,
      fontWeight: BRTypography.bodyWeight,
      color: BRColors.text,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: BRTypography.bodySize,
      fontWeight: BRTypography.bodyWeight,
      color: BRColors.textSecondary,
      height: 1.5,
    ),
    // Caption 13/400
    bodySmall: GoogleFonts.inter(
      fontSize: BRTypography.captionSize,
      fontWeight: BRTypography.captionWeight,
      color: BRColors.textSecondary,
      height: 1.4,
    ),
  ),
  
  // Button Themes with larger tap targets and shadows
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: BRColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52), // Larger tap target
      shadowColor: Colors.black.withValues(alpha: 0.08),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BRRadius.standard),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: BRTypography.bodySize,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: BRColors.primary,
      side: BorderSide(color: BRColors.border, width: 1.5),
      minimumSize: const Size(double.infinity, 52), // Larger tap target
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BRRadius.standard),
      ),
    ),
  ),
  
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: BRColors.primary,
      minimumSize: const Size(48, 48), // Larger tap target
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BRRadius.standard),
      borderSide: BorderSide(color: BRColors.border, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BRRadius.standard),
      borderSide: BorderSide(color: BRColors.border, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BRRadius.standard),
      borderSide: BorderSide(color: BRColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BRRadius.standard),
      borderSide: BorderSide(color: BRColors.error, width: 1.5),
    ),
    contentPadding: const EdgeInsets.all(BRSpacing.lg), // More padding
    hintStyle: GoogleFonts.inter(
      color: BRColors.textSecondary,
      fontSize: BRTypography.bodySize,
    ),
    labelStyle: GoogleFonts.inter(
      color: BRColors.textSecondary,
      fontSize: BRTypography.captionSize,
    ),
  ),
  
  // Floating Action Button Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: BRColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BRRadius.standard),
    ),
  ),
  
  // Tab Bar Theme
  tabBarTheme: TabBarThemeData(
    labelColor: BRColors.primary,
    unselectedLabelColor: BRColors.textSecondary,
    indicator: BoxDecoration(
      color: BRColors.primary,
      borderRadius: BorderRadius.circular(BRRadius.chip),
    ),
    labelStyle: GoogleFonts.inter(
      fontSize: BRTypography.bodySize,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.inter(
      fontSize: BRTypography.bodySize,
      fontWeight: FontWeight.w400,
    ),
  ),
  
  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return BRColors.primary;
      }
      return BRColors.border;
    }),
  ),
  
  // Divider Theme
  dividerTheme: DividerThemeData(
    color: BRColors.divider,
    thickness: 1,
    space: 1,
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: BRColors.primary,
    unselectedItemColor: BRColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  ),
);

// Main theme exports
ThemeData get lightTheme => calmingLightTheme;
ThemeData get darkTheme => calmingLightTheme;