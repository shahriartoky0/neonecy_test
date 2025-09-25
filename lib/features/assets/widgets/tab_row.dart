import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/features/assets/controllers/assets_controller.dart';

import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';

class TabRow extends StatelessWidget {
  final AssetsController controller = Get.put(AssetsController());

  TabRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: <Widget>[
          // Crypto Tab
          Obx(
            () => _buildTabButton(
              text: 'Crypto',
              isSelected: controller.selectedBottomTab.value == 'Crypto',
              onTap: () => controller.selectBottomTab('Crypto'),
            ),
          ),

          // Account Tab
          Obx(
            () => _buildTabButton(
              text: 'Account',
              isSelected: controller.selectedBottomTab.value == 'Account',
              onTap: () => controller.selectBottomTab('Account'),
            ),
          ),

          // Spacer to push icons to the right
          const Spacer(),

          // Search Icon
          IconButton(
            onPressed: () {
              // Search functionality
              print('Search pressed');
            },
            icon: const Icon(CupertinoIcons.search, color: AppColors.textGreyLight, size: 20),
          ),

          // Settings Icon
          IconButton(
            onPressed: () {
              print('Settings pressed');
            },
            icon: CustomSvgImage(assetName: AppIcons.setting, height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        child: Column(
          spacing: 5,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                color: isSelected ? AppColors.textWhite : AppColors.textGreyLight,
                fontSize: 16,
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
