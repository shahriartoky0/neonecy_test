import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/design/app_images.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settins_tile.dart';

class EditProfileScreen extends GetView<SettingsController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    return Scaffold(
      appBar: AppBar(
         leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.white),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textWhite)),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {},
            child: const Text('Save', style: TextStyle(color: AppColors.yellow)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSizes.md,
          children: <Widget>[
            const Text('Personal Information'),

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

            const Text('Enter Name'),
            TextFormField(decoration: const InputDecoration(hintText: 'Enter your name ')),
            const Text('Binance ID'),
            TextFormField(decoration: const InputDecoration(hintText: 'Change Your Binance ID')),
          ],
        ),
      ),
    );
  }
}
