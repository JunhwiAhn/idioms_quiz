import 'package:flutter/material.dart';

const String _sansJp = 'Noto Sans JP';
const String _serifJp = 'Noto Serif JP';

TextStyle notoSansJp({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? wordSpacing,
  double? height,
  TextDecoration? decoration,
  FontStyle? fontStyle,
}) =>
    TextStyle(
      fontFamily: _sansJp,
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
}) =>
    TextStyle(
      fontFamily: _serifJp,
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
  static const Color _seed = Color(0xFFB03A2E);

  /// Success/correct color, distinct from the red-ish primary seed.
  static const Color correctBg = Color(0xFFDCEBCB);
  static const Color correctFg = Color(0xFF2F5720);
  static const Color correctBorder = Color(0xFF6B9440);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: _sansJp),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _sansJp),
      scaffoldBackgroundColor: const Color(0xFFFAF6F2),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: _sansJp),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: _sansJp),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
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
        color: scheme.surfaceContainerHigh,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static TextStyle idiomDisplay(BuildContext context) => notoSerifJp(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        letterSpacing: 6,
        color: Theme.of(context).colorScheme.onSurface,
      );
}
