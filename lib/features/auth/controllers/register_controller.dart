import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/config/app_url.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/network/network_caller.dart';
import 'package:neonecy_test/core/network/network_response.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';

class RegisterController extends GetxController {
  RxBool isLoading = false.obs;

  /// Step 1 - email + terms
  final TextEditingController emailTEController = TextEditingController();
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final RxBool acceptTerms = true.obs;

  /// Step 2 - password
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  /// Step 3 - profile details
  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController mobileTEController = TextEditingController();
  final GlobalKey<FormState> detailsFormKey = GlobalKey<FormState>();
  final RxnString selectedCountry = RxnString();
  final RxnString selectedGender = RxnString();
  final RxnString selectedLanguage = RxnString();
  final RxnString selectedDob = RxnString();

  String maskedEmail(String email) {
    final int atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return email;
    }
    final String local = email.substring(0, atIndex);
    final String domain = email.substring(atIndex);
    final int visible = local.length <= 4 ? 1 : local.length - 4;
    return '${local.substring(0, visible)}****$domain';
  }

  Future<void> handleRegister({required Map<String, dynamic> formData}) async {
    try {
      isLoading.value = true;
      final NetworkResponse response = await NetworkCaller().postFormData(
        AppUrl.signUp,
        formData: formData,
      );
      LoggerUtils.debug(response.jsonResponse);
      if (response.isSuccess) {
        ToastManager.show(
          icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
          message: response.jsonResponse?['message'] ?? 'Registration Successful',
        );
        await GetStorageModel().save(AppConstants.token, response.jsonResponse?['token'] ?? '');
        Get.offAllNamed(AppRoutes.mainBottomScreen);
      } else {
        ToastManager.show(
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
          message: response.jsonResponse?['message'] ?? 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      LoggerUtils.error('Error Encountered $e');
      ToastManager.show(
        message: 'Error $e',
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    emailTEController.dispose();
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    nameTEController.dispose();
    mobileTEController.dispose();
    super.dispose();
  }
}
