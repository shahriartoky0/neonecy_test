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
import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_modal.dart';
import '../../auth/controllers/login_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settins_tile.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text('Setting', style: TextStyle(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSizes.md,
          children: <Widget>[
            SettingsTile(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              children: <Widget>[
                const Text('Dark Mode', style: TextStyle(color: AppColors.textGreyLight)),
                Switch(
                  value: false,
                  onChanged: (bool value) {},
                  inactiveTrackColor: AppColors.grey,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Personal Information'),
                TextButton.icon(
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.editProfile);
                  },

                  icon: CustomSvgImage(assetName: AppIcons.edit),
                ),
              ],
            ),

            ///========== change profile pic =============
            SettingsTile(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              children: <Widget>[
                const Text('Change Profile Pic', style: TextStyle(color: AppColors.textGreyLight)),
                CircleAvatar(
                  backgroundColor: AppColors.textGreyLight,
                  child: Image.asset(AppImages.dummyProfilePic),
                ),
              ],
            ),

            const SettingsTile(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
              children: <Widget>[
                Text('Enter Name', style: TextStyle(color: AppColors.white)),
                Text('00226545748', style: TextStyle(color: AppColors.textGreyLight)),
              ],
            ),
            const SettingsTile(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
              children: <Widget>[
                Text('Binance ID', style: TextStyle(color: AppColors.white)),
                Text('00226545748', style: TextStyle(color: AppColors.textGreyLight)),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            SettingsTile(
              onTap: () {
                Get.toNamed(AppRoutes.editCoins);
              },
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.md),
              children: const <Widget>[
                Text('Add Your Crypto Address', style: TextStyle(color: AppColors.white)),
                Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            const SizedBox(height: AppSizes.xxxL),
            InkWell(
              splashColor: AppColors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),

              onTap: () {
                Get.offAllNamed(AppRoutes.mainBottomScreen);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.greenAccent),
                ),
                child: const Center(
                  child: Text('BACK HOME', style: TextStyle(color: AppColors.greenAccent)),
                ),
              ),
            ),
            InkWell(
              splashColor: AppColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),

              onTap: () {
                CustomBottomSheet.show(
                  height: context.screenHeight * 0.25,
                  context: context,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Do you want to Logout ?',
                          style: context.txtTheme.titleMedium?.copyWith(color: AppColors.textWhite),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          spacing: AppSizes.sm,
                          children: <Widget>[
                            Expanded(
                              child: AppButton(
                                labelText: 'No',
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                bgColor: AppColors.yellow,
                                textColor: AppColors.black,
                              ),
                            ),
                            Expanded(
                              child: AppButton(
                                labelText: 'Yes',
                                onTap: () {
                                  /// =====> Logout logic =====>
                                  final LoginController loginController = Get.put(
                                    LoginController(),
                                  );
                                  loginController.logOut();
                                },
                                bgColor: AppColors.red,
                                textColor: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    CustomSvgImage(assetName: AppIcons.logOut, height: 20),
                    const Text('LOGOUT', style: TextStyle(color: AppColors.red)),
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
