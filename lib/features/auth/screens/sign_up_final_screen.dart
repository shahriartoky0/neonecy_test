import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import 'package:neonecy_test/features/auth/controllers/sign_up_controller.dart';
import '../widgets/custom_textfield.dart';

class SignUpFinalPage extends GetView<SignUpController> {
  const SignUpFinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> previousMap = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        title: const Text(
          'Enter Your Name',
          style: TextStyle(color: AppColors.white, fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Column(
            children: <Widget>[
              SizedBox(height: context.screenHeight * 0.15),
              const Text('Welcome to Flash Generator', style: TextStyle(fontSize: 22)),
              const SizedBox(height: AppSizes.sm),
              const Text(
                'Just Tell Us your Name to Continue',
                style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
              ),
              const SizedBox(height: AppSizes.xl),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                  color: AppColors.iconBackground,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),

                child: Column(
                  children: <Widget>[
                    const SizedBox(height: AppSizes.md),

                    Form(
                      key: controller.namesFormKey,
                      child: Column(
                        children: <Widget>[
                          CustomTextField(
                            controller: controller.firstNameTEController,
                            hintText: 'Enter Your First Name',
                            prefixIcon: CustomSvgImage(assetName: AppIcons.profile, height: 8),
                            // controller: _telegramController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),
                          CustomTextField(
                            controller: controller.lastNameTEController,
                            hintText: 'Enter Your Last Name',
                            prefixIcon: CustomSvgImage(assetName: AppIcons.profile),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter last name';
                              }

                              return null;
                            },
                          ),
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
                  visible: controller.loader.value == false,
                  replacement: const CustomLoading(),
                  child: AppButton(
                    labelText: 'Complete',
                    onTap: () {
                      if (!controller.namesFormKey.currentState!.validate()) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      final Map<String, String> formData = <String, String>{
                        ...previousMap,
                        'first_name': controller.firstNameTEController.text,
                        'last_name': controller.lastNameTEController.text,
                      };
                      controller.handleSignUp(formData: formData);
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
            ],
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
