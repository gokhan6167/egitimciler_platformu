import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from the "Pusula Egitim v2" Claude Design file.
class PusulaColors {
  PusulaColors._();

  static const primary = Color(0xFF0F7A63);
  static const primaryDark = Color(0xFF0B5E4C);
  static const primarySoft = Color(0xFFEAF3EF);
  static const selection = Color(0xFFDCEDE7);

  static const ink = Color(0xFF1A222C);
  static const body = Color(0xFF5A6470);
  static const slate = Color(0xFF3A434E);
  static const muted = Color(0xFF79828C);
  static const faint = Color(0xFF9AA3AD);

  static const background = Color(0xFFFDFDFC);
  static const surface = Color(0xFFF7F6F3);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFECEAE5);
  static const borderDark = Color(0xFFD8D5CE);
  static const patternA = Color(0xFFF1F0EC);
  static const patternB = Color(0xFFF8F7F4);
}

/// Heading font: Plus Jakarta Sans (body text uses Public Sans via theme).
TextStyle pusulaHeading({
  double fontSize = 28,
  FontWeight fontWeight = FontWeight.w700,
  Color color = PusulaColors.ink,
  double height = 1.15,
  double letterSpacingFactor = -0.02,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: fontSize * letterSpacingFactor,
  );
}

ThemeData pusulaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PusulaColors.primary,
    ).copyWith(
      primary: PusulaColors.primary,
      onPrimary: Colors.white,
      primaryContainer: PusulaColors.primarySoft,
      onPrimaryContainer: PusulaColors.primaryDark,
      surface: PusulaColors.background,
      onSurface: PusulaColors.ink,
      surfaceContainerHighest: PusulaColors.surface,
      outline: PusulaColors.borderDark,
      outlineVariant: PusulaColors.border,
    ),
    scaffoldBackgroundColor: PusulaColors.background,
  );

  final textTheme = GoogleFonts.publicSansTextTheme(base.textTheme).apply(
    bodyColor: PusulaColors.ink,
    displayColor: PusulaColors.ink,
  );

  const pill = StadiumBorder();

  return base.copyWith(
    textTheme: textTheme.copyWith(
      headlineLarge: pusulaHeading(fontSize: 38, fontWeight: FontWeight.w800),
      headlineMedium: pusulaHeading(fontSize: 30),
      headlineSmall: pusulaHeading(fontSize: 24),
      titleLarge: pusulaHeading(fontSize: 20),
      titleMedium: pusulaHeading(fontSize: 17, letterSpacingFactor: -0.01),
      titleSmall: pusulaHeading(fontSize: 14, letterSpacingFactor: 0),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: PusulaColors.background.withValues(alpha: 0.95),
      foregroundColor: PusulaColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleTextStyle: pusulaHeading(fontSize: 18),
      shape: const Border(bottom: BorderSide(color: PusulaColors.border)),
    ),
    cardTheme: const CardThemeData(
      color: PusulaColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        side: BorderSide(color: PusulaColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PusulaColors.primary,
        foregroundColor: Colors.white,
        shape: pill,
        textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PusulaColors.ink,
        side: const BorderSide(color: PusulaColors.borderDark),
        shape: pill,
        textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600, fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PusulaColors.primary,
        shape: pill,
        textStyle: GoogleFonts.publicSans(
            fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: PusulaColors.surface,
      selectedColor: PusulaColors.primarySoft,
      side: const BorderSide(color: PusulaColors.border),
      shape: const StadiumBorder(),
      labelStyle: GoogleFonts.publicSans(
          fontSize: 13, color: PusulaColors.body),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PusulaColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PusulaColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PusulaColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PusulaColors.primary, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PusulaColors.background,
      indicatorColor: PusulaColors.primarySoft,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: PusulaColors.background,
      indicatorColor: PusulaColors.primarySoft,
    ),
    dividerTheme: const DividerThemeData(color: PusulaColors.border),
  );
}

/// Circular compass-dot logo from the design (ring + center dot).
class PusulaLogo extends StatelessWidget {
  const PusulaLogo({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PusulaColors.primary, width: 2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: size * 0.31,
        height: size * 0.31,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: PusulaColors.primary,
        ),
      ),
    );
  }
}
