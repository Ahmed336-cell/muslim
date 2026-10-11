import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Palette {
  static const paper = Color(0xFFF4EFE6);
  static const paperDeep = Color(0xFFEAE3D6);
  static const card = Color(0xFFFBF8F2);
  static const ink = Color(0xFF1F2A24);
  static const inkSoft = Color(0xFF5B6660);
  static const rule = Color(0xFFD5CCBC);
  static const green = Color(0xFF1E4D3A);
  static const greenSoft = Color(0xFFDCE6DF);
  static const brass = Color(0xFFB0812F);
  static const clay = Color(0xFFA9512F);
}

/// UI type. The app rebuilds from the root when the language changes,
/// so reading [arabicUi] at build time is safe.
class Fonts {
  static bool arabicUi = false;

  static TextStyle display(
    double size, {
    Color color = Palette.ink,
    FontWeight weight = FontWeight.w400,
  }) => arabicUi
      ? GoogleFonts.elMessiri(
          fontSize: size * .92,
          color: color,
          fontWeight: weight == FontWeight.w300 ? FontWeight.w400 : weight,
          height: 1.35,
        )
      : GoogleFonts.fraunces(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: 1.05,
          letterSpacing: -0.5,
        );

  static TextStyle body(
    double size, {
    Color color = Palette.ink,
    FontWeight weight = FontWeight.w400,
  }) => arabicUi
      ? GoogleFonts.ibmPlexSansArabic(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: 1.5,
        )
      : GoogleFonts.workSans(
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: 1.35,
        );

  /// Small section caption. Uppercased + tracked in English only;
  /// tracking breaks Arabic letter joining.
  static TextStyle label({Color color = Palette.inkSoft}) => arabicUi
      ? GoogleFonts.ibmPlexSansArabic(
          fontSize: 12.5,
          color: color,
          fontWeight: FontWeight.w600,
        )
      : GoogleFonts.workSans(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        );

  /// Italic quote in English; upright in Arabic, which has no true italic.
  static TextStyle quote(double size, {Color color = Palette.inkSoft}) =>
      arabicUi
      ? body(size, color: color).copyWith(height: 1.7)
      : display(
          size,
          color: color,
        ).copyWith(fontStyle: FontStyle.italic, height: 1.45);

  /// Sacred Arabic text (Quran, duas, names) in every language.
  static TextStyle arabic(double size, {Color color = Palette.ink}) =>
      GoogleFonts.amiri(fontSize: size, color: color, height: 1.9);

  static TextStyle mono(double size, {Color color = Palette.ink}) => arabicUi
      ? GoogleFonts.ibmPlexSansArabic(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w500,
        )
      : GoogleFonts.ibmPlexMono(
          fontSize: size,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Palette.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.green,
      primary: Palette.green,
      surface: Palette.paper,
    ),
  );
  return base.copyWith(
    textTheme: Fonts.arabicUi
        ? GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme)
        : GoogleFonts.workSansTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Palette.paper,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      foregroundColor: Palette.ink,
      centerTitle: false,
      titleTextStyle: Fonts.display(24),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Palette.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Palette.greenSoft,
      height: 68,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => Fonts.body(
          12,
          color: s.contains(WidgetState.selected)
              ? Palette.green
              : Palette.inkSoft,
          weight: s.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: 24,
          color: s.contains(WidgetState.selected)
              ? Palette.green
              : Palette.inkSoft,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Palette.ink,
      behavior: SnackBarBehavior.floating,
      contentTextStyle: Fonts.body(14, color: Palette.paper),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.paper,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: Palette.rule,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Palette.rule,
      thickness: .7,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Palette.green,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Palette.clay),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: Palette.card,
        selectedBackgroundColor: Palette.greenSoft,
        selectedForegroundColor: Palette.green,
        foregroundColor: Palette.inkSoft,
        side: const BorderSide(color: Palette.rule),
        textStyle: Fonts.body(14, weight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.card,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: Fonts.body(15, color: Palette.inkSoft),
      prefixIconColor: Palette.inkSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.rule),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.rule),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Palette.green, width: 1.2),
      ),
    ),
  );
}
