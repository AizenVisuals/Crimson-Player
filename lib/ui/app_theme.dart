import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens extracted from the approved light/dark music-player references.
/// The UI remains monochromatic; no synthetic album cover art is generated.
abstract final class AppColors {
  static const ink = Color(0xFF171C26);
  static const slate = Color(0xFF6C7689);
  static const mist = Color(0xFFA4AAB7);
  static const paper = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFF4F5F7);
  static const graphite = Color(0xFF202633);
  static const darkMuted = Color(0xFF9BA6BA);
  static const darkRaised = Color(0xFF272F3E);
}

class AppTheme {
  static ThemeData light() => _theme(
    brightness: Brightness.light,
    background: AppColors.paper,
    foreground: AppColors.ink,
    secondary: AppColors.slate,
    subtle: AppColors.canvas,
    raised: const Color(0xFFEDEFF3),
  );

  static ThemeData dark() => _theme(
    brightness: Brightness.dark,
    background: AppColors.ink,
    foreground: AppColors.paper,
    secondary: AppColors.darkMuted,
    subtle: AppColors.graphite,
    raised: AppColors.darkRaised,
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color foreground,
    required Color secondary,
    required Color subtle,
    required Color raised,
  }) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    final colors = ColorScheme(
      brightness: brightness,
      primary: foreground,
      onPrimary: background,
      secondary: secondary,
      onSecondary: background,
      error: const Color(0xFFC43B52),
      onError: Colors.white,
      surface: background,
      onSurface: foreground,
      onSurfaceVariant: secondary,
      outline: AppColors.mist,
      surfaceContainerLow: subtle,
      surfaceContainer: subtle,
      surfaceContainerHigh: raised,
    );
    final typography = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: foreground, displayColor: foreground,
    );
    return base.copyWith(
      scaffoldBackgroundColor: background,
      canvasColor: background,
      colorScheme: colors,
      textTheme: typography,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: typography.titleMedium?.copyWith(
          fontWeight: FontWeight.w700, color: foreground, fontSize: 15,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: secondary.withValues(alpha: .12), thickness: .8,
      ),
      iconTheme: IconThemeData(color: foreground),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: raised,
        backgroundColor: subtle,
        side: BorderSide.none,
        labelStyle: typography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: foreground,
          foregroundColor: background,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: typography.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

extension CrimsonColors on BuildContext {
  Color get ink => Theme.of(this).colorScheme.onSurface;
  Color get canvas => Theme.of(this).colorScheme.surface;
  Color get muted => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get subtle => Theme.of(this).colorScheme.surfaceContainerLow;
  Color get raised => Theme.of(this).colorScheme.surfaceContainerHigh;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
