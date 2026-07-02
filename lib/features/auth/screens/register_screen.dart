import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import 'package:neonecy_test/core/utils/validators/app_validation.dart';
import 'package:neonecy_test/features/auth/controllers/register_controller.dart';
import 'package:neonecy_test/features/auth/widgets/auth_checkbox.dart';
import 'package:neonecy_test/features/auth/widgets/auth_top_bar.dart';
import 'package:neonecy_test/features/auth/widgets/or_divider.dart';
import 'package:neonecy_test/features/auth/widgets/social_auth_button.dart';

/// Matches the "Welcome to Binance" reference screen: email entry step.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      appBar: const AuthTopBar(isRoot: true, showHeadphone: true),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Form(
            key: controller.emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Welcome to Binance',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
                const Text(
                  'Email/Phone number',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.sm),
                TextFormField(
                  controller: controller.emailTEController,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidation.validateEmail,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: AppColors.iconBackgroundLight,
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                    hintText: 'Email/Phone (without country code)',
                    hintStyle: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AuthCheckbox(
                        value: controller.acceptTerms.value,
                        onChanged: (bool v) => controller.acceptTerms.value = v,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                            children: <InlineSpan>[
                              const TextSpan(
                                text: "By creating an account, I agree to Binance's ",
                              ),
                              TextSpan(
                                text: 'Privacy Notice',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => ToastManager.show(
                                        message: 'Privacy Notice coming soon',
                                      ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                Obx(
                  () => Visibility(
                    replacement: const CustomLoading(),
                    visible: controller.isLoading.value == false,
                    child: AppButton(
                      labelText: 'Register',
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
                        if (!controller.acceptTerms.value) {
                          ToastManager.show(message: 'Please accept the Privacy Notice');
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        Get.toNamed(
                          AppRoutes.registerPasswordScreen,
                          arguments: <String, dynamic>{
                            'email': controller.emailTEController.text.trim(),
                            'accept_terms_and_condition': controller.acceptTerms.value,
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                const OrDivider(),
                const SizedBox(height: AppSizes.xl),
                SocialAuthButton(
                  icon: const GoogleLogo(),
                  label: 'Continue with Google',
                  onTap: () {},
                ),
                const SizedBox(height: AppSizes.xxl),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Sign up as an entity',
                        style: TextStyle(color: AppColors.yellow, fontSize: 15),
                      ),
                    ),
                    const Text(
                      '  or  ',
                      style: TextStyle(color: AppColors.textGreyLight, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.loginScreen),
                      child: const Text(
                        'Log in',
                        style: TextStyle(color: AppColors.yellow, fontSize: 15),
                      ),
                    ),
                  ],
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
