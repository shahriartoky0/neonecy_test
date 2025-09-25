import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/features/auth/controllers/sign_up_controller.dart';

import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';
import '../widgets/custom_textfield.dart';

class SubmitPasswordScreen extends GetView<SignUpController> {
  const SubmitPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();

          },
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        title: const Text(
          'Submit Password',
          style: TextStyle(color: AppColors.white, fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: Column(
          children: <Widget>[
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm, horizontal: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: <Widget>[
                  CustomTextField(
                    controller: controller.passwordTEController,
                    hintText: 'Enter Password',
                    isPassword: true,
                    prefixIcon: CustomSvgImage(assetName: AppIcons.loginLock, height: 8),
                    // controller: _telegramController,
                    keyboardType: TextInputType.text,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your telegram username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  CustomTextField(
                    controller: controller.confirmPasswordTEController,
                    hintText: 'Confirm Password',
                    isPassword: true,

                    prefixIcon: CustomSvgImage(assetName: AppIcons.loginLock, height: 8),
                    // controller: _telegramController,
                    keyboardType: TextInputType.text,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your telegram username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            /// ==============> Warning container =============>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CustomSvgImage(assetName: AppIcons.warning, height: 30),
                      const Text('Warning'),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  /// ===============> Points ==============>
                  Column(
                    spacing: AppSizes.sm,
                    children: <Widget>[
                      buildPoint(
                        pointText:
                            'This password can never be changed, so make sure to save it securely.',
                      ),
                      buildPoint(
                        pointText: 'Create a password that you will remember for a lifetime.',
                      ),
                      buildPoint(
                        pointText: "Our system is entirely Web3-based, so never make any changes.",
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xxl),
            AppButton(
              labelText: "Submit",
              onTap: () {
                Get.toNamed(AppRoutes.finalSignUp);
              },
              bgColor: AppColors.yellow,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildPoint({required String pointText}) {
    return Row(
      spacing: AppSizes.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomSvgImage(assetName: AppIcons.pointer, color: AppColors.textGreyLight),
        Expanded(
          child: Text(pointText, style: const TextStyle(color: AppColors.textGreyLight)),
        ),
      ],
    );
  }
}
