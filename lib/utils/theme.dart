import 'package:flutter/material.dart';


class AppTheme {
static final Color primary = const Color(0xFF2E7D32);
static final Color accent = const Color(0xFF81C784);


static final ThemeData lightTheme = ThemeData(
primaryColor: primary,
colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
.copyWith(secondary: accent),
scaffoldBackgroundColor: const Color(0xFFF5FFF5),
fontFamily: 'Poppins',
appBarTheme: const AppBarTheme(
backgroundColor: Color(0xFF2E7D32),
foregroundColor: Colors.white,
elevation: 0,
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: accent,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
),
);
}