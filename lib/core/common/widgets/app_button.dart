import 'package:flutter/material.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import '../../config/app_sizes.dart';
import '../../design/app_colors.dart';

class AppButton extends StatelessWidget {
  final String labelText;
  final VoidCallback onTap;
  final double? width;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  final Color bgColor;
  final Color textColor;

  const AppButton({
    super.key,
    required this.labelText,
    required this.onTap,
    this.bgColor = AppColors.red,
    this.textColor = AppColors.white,
    this.width,
    this.padding, this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      color: bgColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        splashColor: textColor.withValues(alpha: 0.2),
        highlightColor: textColor.withValues(alpha: 0.2),
        onTap: () {
          DeviceUtility.hapticFeedback();
          onTap();
        },
        child: Container(
          width: width ?? context.screenWidth,
          padding:
              padding ?? const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
           ),
          child: Text(
            labelText,
            style: textStyle ?? context.txtTheme.labelMedium?.copyWith(color: textColor),
          ).centered,
        ),
      ),
    );
  }
}
