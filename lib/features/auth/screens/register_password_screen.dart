import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/validators/app_validation.dart';
import 'package:neonecy_test/features/auth/controllers/register_controller.dart';
import 'package:neonecy_test/features/auth/widgets/auth_top_bar.dart';

import '../widgets/custom_textfield.dart';

/// Step 2 of registration - create a password. Styled to match the
/// "Enter your password" reference screen.
class RegisterPasswordScreen extends StatelessWidget {
  const RegisterPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> previousMap = Get.arguments as Map<String, dynamic>;
    final RegisterController controller = Get.put(RegisterController());
    final String email = previousMap['email'] as String;

    return Scaffold(
      appBar: const AuthTopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Form(
            key: controller.passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Create a password',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  controller.maskedEmail(email),
                  style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.xxl),
                const Text(
                  'Password',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.sm),
                CustomTextField(
                  controller: controller.passwordTEController,
                  isPassword: true,
                  hintText: '',
                  fillColor: AppColors.iconBackgroundLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                  validator: AppValidation.validatePassword,
                ),
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Confirm Password',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.sm),
                CustomTextField(
                  controller: controller.confirmPasswordTEController,
                  isPassword: true,
                  hintText: '',
                  fillColor: AppColors.iconBackgroundLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                  validator: (String? value) => AppValidation.validateConfirmPassword(
                    controller.passwordTEController.text,
                    value,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                AppButton(
                  labelText: 'Continue',
                  bgColor: AppColors.yellow,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  onTap: () {
                    if (!controller.passwordFormKey.currentState!.validate()) {
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    Get.toNamed(
                      AppRoutes.registerDetailsScreen,
                      arguments: <String, dynamic>{
                        ...previousMap,
                        'password': controller.passwordTEController.text,
                        'password_confirmation': controller.confirmPasswordTEController.text,
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
