import 'package:flutter/material.dart';

// Korean is the primary UI language. Keep the bundled JP faces as a reliable
// fallback for Japanese and Latin glyphs, then fall back to platform CJK fonts.
const String _sansUi = 'Noto Sans KR';
const List<String> _sansFallback = [
  'Noto Sans JP',
  'Malgun Gothic',
  'Apple SD Gothic Neo',
  'sans-serif',
];
const String _serifUi = 'Noto Serif JP';
const List<String> _serifFallback = [
  'Noto Sans KR',
  'Batang',
  'AppleMyungjo',
  'serif',
];

TextStyle notoSansJp({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? wordSpacing,
  double? height,
  TextDecoration? decoration,
  FontStyle? fontStyle,
}) => TextStyle(
  fontFamily: _sansUi,
  fontFamilyFallback: _sansFallback,
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
  wordSpacing: wordSpacing,
  height: height,
  decoration: decoration,
  fontStyle: fontStyle,
);

TextStyle notoSerifJp({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? wordSpacing,
  double? height,
  TextDecoration? decoration,
  FontStyle? fontStyle,
}) => TextStyle(
  fontFamily: _serifUi,
  fontFamilyFallback: _serifFallback,
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  letterSpacing: letterSpacing,
  wordSpacing: wordSpacing,
  height: height,
  decoration: decoration,
  fontStyle: fontStyle,
);

class AppTheme {
  static const Color _seed = Color(0xFFC44720);

  /// Success/correct color, distinct from the red-ish primary seed.
  static const Color correctBg = Color(0xFFDDF8E8);
  static const Color correctFg = Color(0xFF087F5B);
  static const Color correctBorder = Color(0xFF20C997);

  static ThemeData light() {
    final generated = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    final scheme = generated.copyWith(
      primary: const Color(0xFFC44720),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFFFE1D5),
      onPrimaryContainer: const Color(0xFF7A2508),
      secondary: const Color(0xFF007C99),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD8F6FF),
      onSecondaryContainer: const Color(0xFF004E62),
      tertiary: const Color(0xFF8B6500),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFF2B8),
      onTertiaryContainer: const Color(0xFF5F4300),
      surface: Colors.white,
      surfaceContainerHigh: const Color(0xFFFFF4E8),
      surfaceContainerHighest: const Color(0xFFFFEBD8),
      outlineVariant: const Color(0xFFFFC8A8),
    );
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: _sansUi,
      fontFamilyFallback: _sansFallback,
    );
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFBF2),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFBF2),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: notoSerifJp(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: notoSansJp(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static TextStyle idiomDisplay(BuildContext context) => notoSerifJp(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: Theme.of(context).colorScheme.onSurface,
  );
}
