import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/features/auth/controllers/login_controller.dart';
import 'package:neonecy_test/features/auth/widgets/auth_top_bar.dart';

import '../widgets/custom_textfield.dart';

/// Matches the "Enter your password" reference screen.
class LoginPasswordScreen extends GetView<LoginController> {
  const LoginPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'Enter your password',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  controller.maskedIdentifier,
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
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.xl),
                Obx(
                  () => AppButton(
                    labelText: 'Continue',
                    isLoading: controller.isLoading.value,
                    bgColor: AppColors.yellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      controller.handleLogin();
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.yellow, fontSize: 15),
                  ),
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
