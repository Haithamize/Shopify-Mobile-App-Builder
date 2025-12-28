import 'package:flutter/material.dart';
import '../../core/config/merchant_config.dart';

/// Builds ThemeData dynamically from MerchantConfig.
/// This is critical in a white-label app:
/// - Merchant primary color -> colorScheme seed + primary
/// - Merchant secondary color -> scaffold background
/// - Merchant font family -> typography across the app
class AppTheme {
  static ThemeData fromMerchant(MerchantConfig config) {
    final primary = _hexToColor(config.theme.primaryColor);
    final background = _hexToColor(config.theme.secondaryColor);

    // Start from a Material 3 theme seeded by the merchant primary color.
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
        primary: primary,
        background: background,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: config.theme.fontFamily,
    );

    // Refine components to look “UI kit” like:
    // - flat cards
    // - soft borders
    // - modern input fields
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withOpacity(.6), width: 1.4),
        ),
      ),
    );
  }
}

/// Utility: converts hex like "#RRGGBB" or "RRGGBB" to Color
Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  // If only RGB is provided, assume alpha is FF
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}
