import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/design/app_images.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settins_tile.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          spacing: AppSizes.md,
          children: <Widget>[
            SettingsTile(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              children: <Widget>[
                const Text('Dark Mode', style: TextStyle(color: AppColors.textGreyLight)),
                Obx(
                  () => Switch(
                    value: controller.switchValue.value,
                    onChanged: (bool value) {
                      controller.toggleSwitch();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Personal Information'),
                InkWell(
                  splashColor: AppColors.yellow.withValues(alpha: 0.4),
                  onTap: () {
                    Get.toNamed(AppRoutes.editProfile);
                  },
                  child: Row(
                    spacing: 6,
                    children: <Widget>[
                      CustomSvgImage(assetName: AppIcons.edit),
                      const Text('Edit', style: TextStyle(color: AppColors.yellow)),
                    ],
                  ),
                ),
              ],
            ),

            ///========== profile pic =============
            SettingsTile(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              children: <Widget>[
                const Text('Profile Pic', style: TextStyle(color: AppColors.textGreyLight)),
                CircleAvatar(
                  backgroundColor: AppColors.textGreyLight,
                  child: Image.asset(AppImages.dummyProfilePic),
                ),
              ],
            ),

            ///========== Name =============
            const SettingsTile(
              children: <Widget>[
                Text("Name:"),
                Text('Neonecy', style: TextStyle(color: AppColors.textGreyLight)),
              ],
            ),

            ///========== Binance ID =============
            const SettingsTile(
              children: <Widget>[
                Text("Binance ID"),
                Text('12345696', style: TextStyle(color: AppColors.textGreyLight)),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            ///========== Crypto Address =============
            SettingsTile(
              onTap: () {
                Get.toNamed(AppRoutes.editCoins);
              },
              children: const <Widget>[
                Text("Add your crypto address"),
                Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            ///========== Buttons =============>
            InkWell(
              splashColor: AppColors.greenButton.withValues(alpha: 0.2),
              highlightColor: AppColors.greenButton.withValues(alpha: 0.1),

              onTap: () {},
              child: Container(
                width: context.screenWidth,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.greenButton),
                ),
                child: const Text(
                  'BACK HOME',
                  style: TextStyle(color: AppColors.greenButton, fontWeight: FontWeight.w700),
                ).centered,
              ),
            ),
            const SizedBox(height: 3),
            InkWell(
              splashColor: AppColors.red.withValues(alpha: 0.2),
              highlightColor: AppColors.red.withValues(alpha: 0.1),

              onTap: () {},
              child: Container(
                width: context.screenWidth,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red),
                ),
                child: Row(
                  spacing: AppSizes.sm,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomSvgImage(assetName: AppIcons.logOut, height: 20),
                    const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
