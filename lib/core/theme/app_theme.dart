import 'package:flutter/material.dart';
import 'package:kairete/config/app_branding.dart';

class AppTheme {
  AppTheme._();

  /// Colori hub (const — usati dove serve `const` in compile-time).
  static const Color primary = Color(0xFF176249);
  static const Color accent = Color(0xFFC45C3E);
  static const Color appBarBorderBottom = Color(0xFF0F4A35);

  /// Brand attivo (hub o tenant), aggiornato da [applyBranding].
  static Color brandPrimary = primary;
  static Color brandAccent = accent;
  static Color brandAppBarBorder = appBarBorderBottom;

  static const Color headerBg = Color(0xFFE8EAED);
  static const Color footerBg = Color(0xFFE8EAED);
  static const Color cardBorder = Color(0xFFDADCE0);
  static const Color textPrimary = Color(0xFF101840);
  static const Color textSecondary = Color(0xFF696F8C);
  static const Color composeBg = Color(0xFFEEF6FD);
  static const Color feedFooterBg = Color(0xFFF5F5F5);
  static const Color feedItemChromeBg = Color(0xFFEEEEEE);
  static const Color linkBlue = Color(0xFF4A90E2);
  static const Color badgeRed = Color(0xFFE53935);
  static const Color authorName = Color(0xFF1A237E);

  static void applyBranding(AppBrandingProfile profile) {
    brandPrimary = profile.primary;
    brandAccent = profile.accent;
    brandAppBarBorder = profile.appBarBorderBottom;
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandPrimary,
          primary: brandPrimary,
          secondary: brandAccent,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brandPrimary,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      );
}
