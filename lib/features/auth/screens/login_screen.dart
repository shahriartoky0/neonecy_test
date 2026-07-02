import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import 'package:neonecy_test/core/utils/validators/app_validation.dart';
import 'package:neonecy_test/features/auth/controllers/login_controller.dart';
import 'package:neonecy_test/features/auth/widgets/auth_top_bar.dart';
import 'package:neonecy_test/features/auth/widgets/or_divider.dart';
import 'package:neonecy_test/features/auth/widgets/social_auth_button.dart';

/// Matches the "Log in" reference screen: email/phone entry step.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      appBar: const AuthTopBar(isRoot: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: controller.emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Log in',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                const Text(
                  'Email/Phone number',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.sm),
                _ClearableField(
                  controller: controller.emailPhoneTEController,
                  hintText: 'Email/Phone (without country code)',
                  validator: AppValidation.validateEmailOrPhone,
                ),
                const SizedBox(height: AppSizes.xl),
                Obx(
                  () => Visibility(
                    replacement: const CustomLoading(),
                    visible: controller.isLoading.value == false,
                    child: AppButton(
                      labelText: 'Log In',
                      bgColor: AppColors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        if (!controller.emailFormKey.currentState!.validate()) {
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        Get.toNamed(AppRoutes.loginPasswordScreen);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                const OrDivider(),
                const SizedBox(height: AppSizes.xl),
                SocialAuthButton(
                  icon: const PasskeyIcon(),
                  label: 'Continue with Passkey',
                  onTap: () {},
                ),
                const SizedBox(height: AppSizes.md),
                SocialAuthButton(
                  icon: const GoogleLogo(),
                  label: 'Continue with Google',
                  onTap: () {},
                ),
                const SizedBox(height: AppSizes.xxl),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.registerScreen),
                  child: const Text(
                    'Create a Binance Account',
                    style: TextStyle(color: AppColors.yellow, fontSize: 15),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Can't log in?",
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

class _ClearableField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const _ClearableField({required this.controller, required this.hintText, this.validator});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.iconBackground,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textGreyLight, size: 18),
                    onPressed: controller.clear,
                  )
                : null,
          ),
        );
      },
    );
  }
}
