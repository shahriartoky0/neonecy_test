 import 'package:flutter/material.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/extensions/date_time_extensions.dart';

class DatePickerUtils {
  DatePickerUtils._();

  static Future<String?> pickFormatedDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();

    final DateTime? dateTime =  await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 100),
      lastDate: lastDate ?? DateTime(now.year + 10),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blue,
              onPrimary: Colors.white,
              onSurface: AppColors.white,
              surface: AppColors.primaryColor, // background color
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: AppColors.primaryColor,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: AppColors.primaryColor,
            ),
             textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );;

    return dateTime?.formattedDate;
  }

}