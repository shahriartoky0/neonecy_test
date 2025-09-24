import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryColor = Color(0xFF1F2630);
  static const Color blue = Color(0xFF123462);
  static const Color textWhite = Color(0xFFE9ECF1);
  static const Color textGreyLight = Color(0xFF858E9F);
  static const Color textRed = Color(0xFFCD5573);
  static const Color redContainer = Color(0xFF2B2833);
  static const Color greenContainer = Color(0xFF1F2D33);
  static const Color hintText = Color(0xFFA8ACAF);
  static const Color darkRed = Color(0xFF841414);
  static const Color bgColor = Color(0xFF1F2630);
  static const Color orange = Color(0xFFFF8133);
  static const Color yellow = Color(0xFFFCD434);
  static const Color red = Color(0xFFF6455D);
  static const Color black = Color(0xFF111111);
   static const Color grey = Colors.grey;
   static const Color white = Color(0xFFFFFFFF);
   static const Color lightGreen = Color(0xFF3BB487);
  static const Color green = Color(0xFF24A584);
  static const Color greenAccent = Color(0xFF2EBD85);
  static const Color iconBackground = Color(0xFF29313C);
  static const Color iconBackgroundLight = Color(0xFF36404C);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF252D3A), // Lighter top
      Color(0xFF1F2630), // Your primary color
      Color(0xFF141A22), // Darker bottom
    ],
  );
}
