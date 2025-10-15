import 'package:flutter/material.dart';

import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.children, this.padding, this.onTap});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconBackground,
      borderRadius: BorderRadius.circular(8),

      child: InkWell(
        splashColor: AppColors.iconBackground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),

        onTap: onTap,
        child: Container(
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
        ),
      ),
    );
  }
}
