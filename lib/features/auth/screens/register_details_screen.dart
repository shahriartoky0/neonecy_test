import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import 'package:neonecy_test/core/utils/validators/app_validation.dart';
import 'package:neonecy_test/features/auth/controllers/register_controller.dart';
import 'package:neonecy_test/features/auth/utils/auth_options.dart';
import 'package:neonecy_test/features/auth/widgets/auth_picker_field.dart';
import 'package:neonecy_test/features/auth/widgets/auth_top_bar.dart';

import '../widgets/custom_textfield.dart';

/// Step 3 of registration - profile details required by the backend but not
/// present in the reference screens. Styled to match the rest of the flow.
class RegisterDetailsScreen extends StatelessWidget {
  const RegisterDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> previousMap = Get.arguments as Map<String, dynamic>;
    final RegisterController controller = Get.put(RegisterController());

    return Scaffold(
      appBar: const AuthTopBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
          child: Form(
            key: controller.detailsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Tell us about you',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'This information helps us keep your account secure.',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                ),
                const SizedBox(height: AppSizes.xxl),

                const _FieldLabel('Full name'),
                CustomTextField(
                  controller: controller.nameTEController,
                  hintText: 'Enter your full name',
                  fillColor: AppColors.iconBackgroundLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                  validator: AppValidation.validateName,
                ),
                const SizedBox(height: AppSizes.md),

                const _FieldLabel('Country'),
                Obx(
                  () => AuthPickerField(
                    hintText: 'Select your country',
                    items: AuthOptions.countries,
                    value: controller.selectedCountry.value,
                    onSelected: (String v) => controller.selectedCountry.value = v,
                    validator: (String? v) =>
                        AppValidation.validateRequired(v, fieldName: 'Country'),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                const _FieldLabel('Mobile number'),
                CustomTextField(
                  controller: controller.mobileTEController,
                  hintText: 'Enter your mobile number',
                  keyboardType: TextInputType.phone,
                  fillColor: AppColors.iconBackgroundLight,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: AppSizes.sm),
                  validator: AppValidation.validatePhoneNumber,
                ),
                const SizedBox(height: AppSizes.md),

                const _FieldLabel('Gender'),
                Obx(
                  () => AuthPickerField(
                    hintText: 'Select your gender',
                    items: AuthOptions.genders,
                    value: controller.selectedGender.value,
                    searchable: false,
                    onSelected: (String v) => controller.selectedGender.value = v,
                    validator: (String? v) =>
                        AppValidation.validateRequired(v, fieldName: 'Gender'),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                const _FieldLabel('Preferred language'),
                Obx(
                  () => AuthPickerField(
                    hintText: 'Select your preferred language',
                    items: AuthOptions.languages.keys.toList(),
                    value: controller.selectedLanguage.value,
                    onSelected: (String v) => controller.selectedLanguage.value = v,
                    validator: (String? v) =>
                        AppValidation.validateRequired(v, fieldName: 'Preferred language'),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                const _FieldLabel('Date of birth'),
                Obx(
                  () => AuthDateField(
                    hintText: 'Select your date of birth',
                    value: controller.selectedDob.value,
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                    onSelected: (String v) => controller.selectedDob.value = v,
                    validator: (String? v) =>
                        AppValidation.validateRequired(v, fieldName: 'Date of birth'),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                Obx(
                  () => Visibility(
                    replacement: const CustomLoading(),
                    visible: controller.isLoading.value == false,
                    child: AppButton(
                      labelText: 'Complete Registration',
                      bgColor: AppColors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        if (!controller.detailsFormKey.currentState!.validate()) {
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        controller.handleRegister(
                          formData: <String, dynamic>{
                            ...previousMap,
                            'name': controller.nameTEController.text.trim(),
                            'country': controller.selectedCountry.value,
                            'mobile': controller.mobileTEController.text.trim(),
                            'gender': controller.selectedGender.value?.toLowerCase(),
                            'preferred_language':
                                AuthOptions.languages[controller.selectedLanguage.value] ?? 'en',
                            'date_of_birth': controller.selectedDob.value,
                          },
                        );
                      },
                    ),
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(text, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
    );
  }
}
