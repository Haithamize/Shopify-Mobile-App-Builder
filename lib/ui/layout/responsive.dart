import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Responsive design tokens for the whole app.
///
/// Goals:
/// - One reusable system for ALL screens
/// - No magic numbers scattered across UI code
/// - Works on small phones, big phones, foldables, tablets
/// - Keeps performance: only reads MediaQuery once per build usage
///
/// How to use:
/// final r = Responsive.of(context);
/// padding: EdgeInsets.all(r.gutter);
/// radius: r.radiusLg
/// heroHeight: r.heroHeight
/// gridCols: r.columns(minTileWidth: 190)
class Responsive {
  Responsive._(this.size);

  final Size size;

  static Responsive of(BuildContext context) {
    // Reading MediaQuery is cheap and standard.
    // This creates a lightweight object holding width/height.
    return Responsive._(MediaQuery.sizeOf(context));
  }

  double get w => size.width;
  double get h => size.height;

  // --------------------------------------------------------------------------
  // Breakpoints (used sparingly; prefer formulas + clamp)
  // --------------------------------------------------------------------------
  bool get isSmall => w < 360;
  bool get isTablet => w >= 600;
  bool get isLargeTablet => w >= 900;

  // --------------------------------------------------------------------------
  // Spacing system (gutter / spacing scale)
  // --------------------------------------------------------------------------
  /// Base gutter scales with width, clamped to avoid extremes.
  double get gutter => (w * 0.045).clamp(14.0, 24.0);

  /// A spacing scale so designers/devs can use consistent increments
  double get s1 => (gutter * 0.25).clamp(4.0, 8.0);
  double get s2 => (gutter * 0.5).clamp(8.0, 12.0);
  double get s3 => gutter; // primary spacing
  double get s4 => (gutter * 1.5).clamp(18.0, 36.0);
  double get s5 => (gutter * 2.0).clamp(24.0, 48.0);

  // --------------------------------------------------------------------------
  // Radius system
  // --------------------------------------------------------------------------
  double get radiusSm => (w * 0.025).clamp(10.0, 14.0);
  double get radiusMd => (w * 0.032).clamp(12.0, 18.0);
  double get radiusLg => (w * 0.04).clamp(14.0, 22.0);

  // --------------------------------------------------------------------------
  // Component sizing helpers (reusable across screens)
  // --------------------------------------------------------------------------
  /// Hero/banner height scales with width.
  double get heroHeight => (w * 0.56).clamp(180.0, 270.0);

  /// Horizontal card width (for category chips/cards). Scales with width.
  double get hCardWidth => (w * 0.36).clamp(120.0, 170.0);

  /// Horizontal card row height derived from card width (keeps consistent aspect).
  double get hCardHeight => (hCardWidth * 0.92).clamp(110.0, 150.0);

  /// Computes number of columns for grids based on minimum desired tile width.
  /// Keeps it stable and predictable across screens.
  int columns({required double minTileWidth, int min = 2, int max = 4}) {
    final cols = (w / minTileWidth).floor();
    return cols.clamp(min, max);
  }

  /// Computes a reasonable child aspect ratio for product tiles.
  /// You can also pass explicit ratios in a screen if design requires it.
  double get productAspect => (w >= 500) ? 0.78 : 0.72;
  double get featuredAspect => (w >= 500) ? 1.0 : 0.92;

  // --------------------------------------------------------------------------
  // Typography scaling (optional)
  // --------------------------------------------------------------------------
  /// Subtle text scale clamp to avoid huge fonts on very large screens
  double get textScale {
    // Respect OS accessibility but clamp for layout stability
    // NOTE: You can remove clamp if you want full accessibility scaling.
    return math.min(1.15, math.max(0.95, w / 390));
  }
}

/// Convenience extension:
/// final r = context.r;
extension ResponsiveX on BuildContext {
  Responsive get r => Responsive.of(this);
}
