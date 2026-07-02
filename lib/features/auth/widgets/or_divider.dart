import 'package:flutter/material.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(child: Divider(color: AppColors.textGreyLight, thickness: 0.3)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.sm),
          child: Text('or', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
        ),
        Expanded(child: Divider(color: AppColors.textGreyLight, thickness: 0.3)),
      ],
    );
  }
}