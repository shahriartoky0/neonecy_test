import 'package:flutter/material.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class AppTheme {
  static ThemeData defaultThemeData = ThemeData(
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.bgColor, centerTitle: true),
    useMaterial3: true,
    //font family
    scaffoldBackgroundColor: AppColors.bgColor,
    // colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    iconTheme: const IconThemeData(opacity: 1, color: AppColors.white),
    fontFamily: 'inter',
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.iconBackground,
      labelStyle: TextStyle(
        color: AppColors.primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: AppColors.hintText,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      iconColor: AppColors.textGreyLight,
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: AppSizes.sm),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.textGreyLight,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      /// Id name header text ========>
      labelLarge: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w700),

      /// Button Text  =====>
      labelMedium: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),

      /// Navbar label ====>
      labelSmall: TextStyle(color: AppColors.textWhite, fontSize: 10, fontWeight: FontWeight.w500),

      displayMedium: TextStyle(color: AppColors.white, fontSize: 34, fontWeight: FontWeight.w700),

      /// ========> for the regular text === >
      bodyMedium: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),
      bodySmall: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w400),
      titleMedium: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),

      /// Card title ======>
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    dividerColor: AppColors.white,
    dividerTheme: const DividerThemeData(color: AppColors.white),
  );
}
