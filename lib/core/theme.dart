import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_settings.dart';

/// Color palette pulled directly from the ElderCare Figma design.
///
/// Brand colors (primary/secondary/danger/warning/accentGreen/white) stay
/// identical in light and dark mode. Everything else (background, surface,
/// text, borders, status card tints) is exposed as a `static Color get`
/// that reads the current [AppSettings.instance.isDark] flag, so every
/// screen that already writes `AppColors.background`, `AppColors.dark`,
/// `AppColors.grey` etc. automatically renders correctly in both themes
/// with no per-screen changes required.
class AppColors {
  // Brand / semantic colors — identical across themes.
  static const Color primary = Color(0xFF2E7D6B); // Deep teal green
  static const Color secondary = Color(0xFF7CC9A5); // Light teal
  static const Color accentGreen = Color(0xFF4CAF50); // Success / positive
  static const Color danger = Color(0xFFE53935); // SOS / alerts
  static const Color warning = Color(0xFFFFB300); // Pending / amber
  static const Color white = Color(0xFFFFFFFF); // Pure white — icons/text on saturated brand backgrounds

  static bool get _isDark => AppSettings.instance.isDark;

  // ---- Light palette ---------------------------------------------------
  static const Color _backgroundLight = Color(0xFFF7F9FB);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _textPrimaryLight = Color(0xFF1F2937);
  static const Color _textSecondaryLight = Color(0xFF9CA3AF);
  static const Color _borderLight = Color(0xFFE5E7EB);
  static const Color _cardBorderLight = Color(0xFFEFF2F5);

  // ---- Dark palette ------------------------------------------------------
  static const Color _backgroundDark = Color(0xFF10141C);
  static const Color _surfaceDark = Color(0xFF1B212C);
  static const Color _textPrimaryDark = Color(0xFFECEFF4);
  static const Color _textSecondaryDark = Color(0xFF9AA5B5);
  static const Color _borderDark = Color(0xFF2C3444);
  static const Color _cardBorderDark = Color(0xFF262E3B);

  /// Page/scaffold background.
  static Color get background => _isDark ? _backgroundDark : _backgroundLight;

  /// Card / input / nav-bar surface background (replaces raw "white" used as a surface).
  static Color get surface => _isDark ? _surfaceDark : _surfaceLight;

  /// Primary text/icon color. Kept as `dark` for backward compatibility with
  /// existing call sites — resolves to a light color in dark mode.
  static Color get dark => _isDark ? _textPrimaryDark : _textPrimaryLight;

  /// Secondary / muted text color.
  static Color get grey => _isDark ? _textSecondaryDark : _textSecondaryLight;

  /// General borders / dividers.
  static Color get lightGrey => _isDark ? _borderDark : _borderLight;

  /// Subtle card borders.
  static Color get cardBorder => _isDark ? _cardBorderDark : _cardBorderLight;

  // Status backgrounds used on the dashboard / health cards.
  static Color get bpCard => _isDark ? const Color(0xFF3A2523) : const Color(0xFFFDEBEA);
  static Color get sugarCard => _isDark ? const Color(0xFF2E2739) : const Color(0xFFF3E8FD);
  static Color get weightCard => _isDark ? const Color(0xFF1D2A38) : const Color(0xFFE8F3FD);
  static Color get pulseCard => _isDark ? const Color(0xFF251F3A) : const Color(0xFFEDE7FB);
}

class AppTheme {
  /// Builds a fresh [ThemeData] reflecting the current dark/light setting.
  /// Not `const` on purpose — call it fresh on every rebuild (the app root
  /// rebuilds via a `ListenableBuilder` on [AppSettings.instance]) so it
  /// always reflects the latest theme.
  static ThemeData get themeData {
    final isDark = AppSettings.instance.isDark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.danger,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.dark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.dark,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grey,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.dark),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(color: AppColors.grey, fontSize: 15),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return isDark ? AppColors.grey : null;
        }),
      ),
    );
  }
}
