import 'package:flutter/material.dart';

import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class AddFundModalTile extends StatelessWidget {
  final VoidCallback onTap;

  final String title;

  final String subTitle;
  final Widget leadingWidget;

  const AddFundModalTile({
    super.key,
    required this.onTap,
    required this.title,
    required this.subTitle,
    required this.leadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.iconBackgroundLight),
          borderRadius: BorderRadius.circular(AppSizes.sm),
        ),
        child: Row(
          spacing: AppSizes.md,
          children: <Widget>[
            leadingWidget,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subTitle,
                    style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
