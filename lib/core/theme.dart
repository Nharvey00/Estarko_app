import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: const Color(0xFFE11D48),
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE11D48),
    primary: const Color(0xFFE11D48),
  ),
  textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  appBarTheme: const AppBarTheme(
    scrolledUnderElevation: 0,
    elevation: 0,
    backgroundColor: Colors.transparent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 8,
      shadowColor: const Color(0x40E11D48),
      backgroundColor: const Color(0xFFE11D48),
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
    ),
  ),
);
