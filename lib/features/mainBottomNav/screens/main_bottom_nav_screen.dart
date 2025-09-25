import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/features/mainBottomNav/controllers/main_bottom_nav_controller.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/design/app_colors.dart';

class MainBottomNavScreen extends GetView<MainBottomNavController> {
  const MainBottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        itemCount: controller.screens.length,
        itemBuilder: (BuildContext context, int index) {
          return controller.screens[index];
        },
      ),
      bottomNavigationBar: Container(
        color: AppColors.primaryColor,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8, // Respects safe area
        ),
        child: Obx(
              () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              controller.icons.length,
                  (int index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return GestureDetector(
      onTap: () => controller.navigateToTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: prevents extra space
        // spacing: AppSizes.sm,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: CustomSvgImage(
              height: 20,
              assetName: controller.icons[index],
              color: controller.isTabSelected(index)
                  ? AppColors.yellow
                  : AppColors.textGreyLight,
            ),
          ),
          Text(
            controller.labels[index],
            style: TextStyle(
              fontSize: 10,
              color: controller.isTabSelected(index)
                  ? AppColors.textWhite
                  : AppColors.textGreyLight,
            ),
          ),
        ],
      ),
    );
  }
}