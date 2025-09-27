import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import 'package:neonecy_test/core/utils/swipe_wrapper.dart';
import 'package:neonecy_test/features/auth/controllers/login_controller.dart';
import 'package:neonecy_test/features/auth/controllers/sign_up_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.put(LoginController());
    final SignUpController signUpController = Get.put(SignUpController());
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
            child: Column(
              children: <Widget>[
                const Text('Welcome to Flash', style: TextStyle(fontSize: 22)),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Please login to your account',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                ),
                const SizedBox(height: AppSizes.xl),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                    color: AppColors.iconBackgroundLight,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),

                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppSizes.md),
                      const Text('Account Login', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: AppSizes.md),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(
                          () => FastDragWrapper(
                            sensitivity: 40.0,
                            // Lower = more sensitive
                            velocityThreshold: 250.0,
                            // Lower = easier quick swipes
                            showFeedback: false,
                            // Disable for maximum speed
                            onDragComplete: (int direction) {
                              controller.selectTab(direction == 1 ? 0 : 1);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                              child: Row(
                                children: <Widget>[
                                  topTabButton(
                                    label: 'Login',
                                    isSelected: controller.isLoginTabSelected(),
                                    onTap: () {
                                      controller.selectTab(0);
                                    },
                                  ),
                                  topTabButton(
                                    label: 'Signup',
                                    isSelected: controller.isSignUpTabSelected(),
                                    onTap: () {
                                      controller.selectTab(1);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      Obx(
                        () => controller.isLoginTabSelected()
                            ?
                              /// =========> login page ===========>
                              Form(
                                key: loginController.loginFormKey,
                                child: Column(
                                  children: <Widget>[
                                    CustomTextField(
                                      controller: loginController.userNameTEController,
                                      hintText: 'Enter Your Telegram User Name',
                                      prefixIcon: CustomSvgImage(
                                        assetName: AppIcons.loginUser,
                                        height: 8,
                                      ),
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
                                      controller: loginController.passwordTEController,
                                      isPassword: true,
                                      hintText: 'Enter a password',
                                      prefixIcon: CustomSvgImage(assetName: AppIcons.loginLock),
                                      // controller: _telegramController,
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            :
                              /// ======= Signup Page =========>
                              Column(
                                children: <Widget>[
                                  Form(
                                    key: signUpController.userNameFormKey,
                                    child: CustomTextField(
                                      controller: signUpController.userNameTEController,
                                      hintText: 'Enter Your Telegram User Name',
                                      prefixIcon: CustomSvgImage(
                                        assetName: AppIcons.loginUser,
                                        height: 8,
                                      ),
                                      // controller: _telegramController,
                                      keyboardType: TextInputType.text,
                                      validator: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your telegram username';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.xxl),
                                  const SizedBox(height: AppSizes.md),
                                  const SizedBox(height: AppSizes.md),
                                ],
                              ),
                      ),

                      const SizedBox(height: AppSizes.md),

                      ///=========> Login Button ====>
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),

                Obx(
                  () => Visibility(
                    replacement: const CustomLoading(),
                    visible: loginController.isLoading.value == false,
                    child: AppButton(
                      labelText: controller.isLoginTabSelected() ? 'Login' : 'Continue',
                      onTap: () {
                        if (controller.isSignUpTabSelected()) {
                          if (!signUpController.userNameFormKey.currentState!.validate()) {
                            return;
                          }
                          Get.toNamed(
                            AppRoutes.submitPassword,
                            arguments: <String, String>{
                              'user_name': signUpController.userNameTEController.text,
                            },
                          );
                        } else {
                          /// =========== Login logic ====>
                          FocusScope.of(context).unfocus();
                          loginController.handleLogin();
                        }
                      },
                      bgColor: AppColors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded topTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.yellow : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
              color: isSelected ? AppColors.primaryColor : AppColors.textGreyLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 16,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
