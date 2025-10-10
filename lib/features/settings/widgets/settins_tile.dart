import 'package:flutter/material.dart';

import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      padding ?? const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
    );
  }
}