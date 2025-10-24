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
    final TextEditingController nameController = TextEditingController(
      text: controller.userName.value,
    );
    final TextEditingController binanceController = TextEditingController(
      text: controller.binanceId.value,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.white),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textWhite)),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              controller.updateUsername(nameController.text);
              controller.updateBinanceId(binanceController.text);
              controller.saveProfile();
            },
            child: const Text('Save', style: TextStyle(color: AppColors.yellow)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          spacing: AppSizes.md,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Personal Information'),

            // Profile Picture Section
            SettingsTile(
              onTap: controller.pickProfileImage,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              children: <Widget>[
                const Text('Change Profile Pic', style: TextStyle(color: AppColors.textGreyLight)),
                Obx(() {
                  return CircleAvatar(
                    backgroundColor: AppColors.textGreyLight,
                    backgroundImage: controller.profileImage.value != null
                        ? FileImage(controller.profileImage.value!)
                        : AssetImage(AppImages.dummyProfilePic) as ImageProvider,
                  );
                }),
              ],
            ),

            const Text('Enter Name'),
            TextFormField(
              style: const TextStyle(color: AppColors.textWhite),
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),

            const Text('Binance ID'),
            TextFormField(
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textWhite),
              controller: binanceController,
              decoration: const InputDecoration(hintText: 'Change Your Binance ID'),
            ),
          ],
        ),
      ),
    );
  }
}
