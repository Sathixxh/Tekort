import 'package:flutter/material.dart';
import 'package:tekort/core/core/utils/styles.dart';

class AppTheme {
  static ThemeData lightThemeMode(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: secondaryColor,
      drawerTheme: const DrawerThemeData(backgroundColor: secondaryColor),
      primaryColor: primaryColor,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        background: secondaryColor,
        surfaceTint: primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: const Color.fromARGB(77, 216, 216, 216),
  labelStyle: const TextStyle(color: primaryColor),
  prefixIconColor: primaryColor,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: primaryColor, width: 2),
  ),
),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData darkThemeMode(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: blackColor,
      drawerTheme: const DrawerThemeData(backgroundColor: blackColor),
      primaryColor: primaryColor,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        background: blackColor,
        surfaceTint: blackColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: const Color.fromRGBO(66, 66, 66, 0.3),
  labelStyle: const TextStyle(color: primaryColor),
  prefixIconColor: primaryColor,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: primaryColor, width: 2),
  ),
),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blackColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}
