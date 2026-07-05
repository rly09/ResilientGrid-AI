import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppColors {
  static const Color primary = Color(0xFF0A0A0A);
  static const Color primaryActive = Color(0xFF1F1F1F);
  static const Color primaryDisabled = Color(0xFFE5E5E5);
  static const Color ink = Color(0xFF0A0A0A);
  static const Color body = Color(0xFF3A3A3A);
  static const Color bodyStrong = Color(0xFF1A1A1A);
  static const Color muted = Color(0xFF6A6A6A);
  static const Color mutedSoft = Color(0xFF9A9A9A);
  static const Color hairline = Color(0xFFE5E5E5);
  static const Color hairlineSoft = Color(0xFFF0F0F0);
  static const Color canvas = Color(0xFFFFFAF0);
  static const Color surfaceSoft = Color(0xFFFAF5E8);
  static const Color surfaceCard = Color(0xFFF5F0E0);
  static const Color surfaceStrong = Color(0xFFEBE6D6);
  static const Color surfaceDark = Color(0xFF0A1A1A);
  static const Color surfaceDarkElevated = Color(0xFF1A2A2A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkSoft = Color(0xFFA0A0A0);
  static const Color brandPink = Color(0xFFFF4D8B);
  static const Color brandTeal = Color(0xFF1A3A3A);
  static const Color brandLavender = Color(0xFFB8A4ED);
  static const Color brandPeach = Color(0xFFFFB084);
  static const Color brandOchre = Color(0xFFE8B94A);
  static const Color brandMint = Color(0xFFA4D4C5);
  static const Color brandCoral = Color(0xFFFF6B5A);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Backward compatibility aliases for old theme
  static const Color cafeNoir = primary;
  static const Color kombuGreen = brandTeal;
  static const Color mossGreen = brandMint;
  static const Color tan = brandOchre;
  static const Color bone = canvas;

  static const List<Color> featureCardColors = [
    brandPink,
    brandTeal,
    brandLavender,
    brandPeach,
    brandOchre,
    surfaceCard,
  ];

  static const List<Color> featureCardTextColors = [
    onPrimary,
    onDark,
    ink,
    ink,
    ink,
    ink,
  ];
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double section = 96;
}

class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 9999;
  static const double full = 9999;
}

class AppTextStyles {
  static TextStyle displayXL = GoogleFonts.inter(
    fontSize: 72,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -2.5,
    color: AppColors.ink,
  );

  static TextStyle displayLG = GoogleFonts.inter(
    fontSize: 56,
    fontWeight: FontWeight.w500,
    height: 1.05,
    letterSpacing: -2,
    color: AppColors.ink,
  );

  static TextStyle displayMD = GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -1,
    color: AppColors.ink,
  );

  static TextStyle displaySM = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: -0.5,
    color: AppColors.ink,
  );

  static TextStyle titleLG = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static TextStyle titleMD = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.ink,
  );

  static TextStyle titleSM = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.ink,
  );

  static TextStyle bodyMD = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0,
    color: AppColors.body,
  );

  static TextStyle bodySM = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    letterSpacing: 0,
    color: AppColors.body,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.muted,
  );

  static TextStyle captionUppercase = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 1.5,
    color: AppColors.muted,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
    color: AppColors.onPrimary,
  );

  static TextStyle navLink = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.ink,
  );
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class AppTheme {
  static bool isDark = false;

  // Backward compatibility color getters
  static Color get cafeNoir => isDark ? const Color(0xFFFFFFFF) : AppColors.primary;
  static Color get kombuGreen => isDark ? AppColors.brandMint : AppColors.brandTeal;
  static Color get mossGreen => isDark ? const Color(0xFF5CD8A7) : AppColors.brandMint;
  static Color get tan => isDark ? const Color(0xFF2E3E3E) : AppColors.brandOchre;
  static Color get bone => isDark ? AppColors.surfaceDarkElevated : AppColors.canvas;

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.brandTeal,
        surface: AppColors.canvas,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onDark,
        onSurface: AppColors.ink,
        onError: AppColors.onPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTextStyles.displayXL,
        displayMedium: AppTextStyles.displayLG,
        displaySmall: AppTextStyles.displayMD,
        headlineLarge: AppTextStyles.displaySM,
        headlineMedium: AppTextStyles.titleLG,
        headlineSmall: AppTextStyles.titleMD,
        titleLarge: AppTextStyles.titleLG,
        titleMedium: AppTextStyles.titleMD,
        titleSmall: AppTextStyles.titleSM,
        bodyLarge: AppTextStyles.bodyMD,
        bodyMedium: AppTextStyles.bodyMD,
        bodySmall: AppTextStyles.bodySM,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.navLink,
        labelSmall: AppTextStyles.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.navLink.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        toolbarHeight: 64,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.ink,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: AppColors.hairline, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.muted),
        hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.mutedSoft),
      ),
      cardTheme: CardThemeData(
        color: AppColors.canvas,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceCard,
        selectedColor: AppColors.surfaceCard,
        disabledColor: AppColors.hairlineSoft,
        labelStyle: AppTextStyles.caption,
        secondaryLabelStyle: AppTextStyles.caption.copyWith(color: AppColors.ink),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: const BorderSide(color: AppColors.hairline, width: 1),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.muted,
        labelStyle: AppTextStyles.navLink,
        unselectedLabelStyle: AppTextStyles.navLink,
        indicator: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? AppColors.hairlineSoft
              : null,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.canvas,
        indicatorColor: AppColors.surfaceCard,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.navLink.copyWith(color: AppColors.ink)
              : AppTextStyles.navLink.copyWith(color: AppColors.muted),
        ),
        height: 64,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.onPrimary,
        secondary: AppColors.brandMint,
        surface: AppColors.surfaceDarkElevated,
        error: AppColors.error,
        onPrimary: AppColors.primary,
        onSecondary: AppColors.surfaceDark,
        onSurface: AppColors.onDark,
        onError: AppColors.onPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTextStyles.displayXL.copyWith(color: AppColors.onPrimary),
        displayMedium: AppTextStyles.displayLG.copyWith(color: AppColors.onPrimary),
        displaySmall: AppTextStyles.displayMD.copyWith(color: AppColors.onPrimary),
        headlineLarge: AppTextStyles.displaySM.copyWith(color: AppColors.onPrimary),
        headlineMedium: AppTextStyles.titleLG.copyWith(color: AppColors.onPrimary),
        headlineSmall: AppTextStyles.titleMD.copyWith(color: AppColors.onPrimary),
        titleLarge: AppTextStyles.titleLG.copyWith(color: AppColors.onPrimary),
        titleMedium: AppTextStyles.titleMD.copyWith(color: AppColors.onPrimary),
        titleSmall: AppTextStyles.titleSM.copyWith(color: AppColors.onPrimary),
        bodyLarge: AppTextStyles.bodyMD.copyWith(color: AppColors.onDarkSoft),
        bodyMedium: AppTextStyles.bodyMD.copyWith(color: AppColors.onDarkSoft),
        bodySmall: AppTextStyles.bodySM.copyWith(color: AppColors.onDarkSoft),
        labelLarge: AppTextStyles.button.copyWith(color: AppColors.primary),
        labelMedium: AppTextStyles.navLink.copyWith(color: AppColors.onDarkSoft),
        labelSmall: AppTextStyles.caption.copyWith(color: AppColors.onDarkSoft),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.onDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.navLink.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onDark),
        toolbarHeight: 64,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onPrimary,
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.onPrimary,
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceDarkElevated,
          foregroundColor: AppColors.onDark,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: AppColors.hairline, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.onDark,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.brandMint, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        labelStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.onDarkSoft),
        hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.mutedSoft),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDarkElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.hairline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDarkElevated,
        selectedColor: AppColors.brandTeal,
        disabledColor: AppColors.hairlineSoft,
        labelStyle: AppTextStyles.caption.copyWith(color: AppColors.onDarkSoft),
        secondaryLabelStyle: AppTextStyles.caption.copyWith(color: AppColors.onDark),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        side: const BorderSide(color: AppColors.hairline, width: 1),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.onDark,
        unselectedLabelColor: AppColors.onDarkSoft,
        labelStyle: AppTextStyles.navLink,
        unselectedLabelStyle: AppTextStyles.navLink,
        indicator: BoxDecoration(
          color: AppColors.brandTeal,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.hovered)
              ? AppColors.hairlineSoft.withValues(alpha: 0.1)
              : null,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.brandTeal,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.navLink.copyWith(color: AppColors.onDark)
              : AppTextStyles.navLink.copyWith(color: AppColors.onDarkSoft),
        ),
        height: 64,
      ),
    );
  }
}