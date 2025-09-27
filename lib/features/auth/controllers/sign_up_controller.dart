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

class SignUpController extends GetxController {
  ///=====> For signup text form controller =====>

  final TextEditingController userNameTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController = TextEditingController();

  ///=====> For signup final  text form controller =====>
  final TextEditingController firstNameTEController = TextEditingController();
  final TextEditingController lastNameTEController = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> userNameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> namesFormKey = GlobalKey<FormState>();

  /// =======Sign up logic ====>
  final RxBool loader = false.obs;

  Future<void> handleSignUp({required Map<String, String> formData}) async {
    try {
      if (firstNameTEController.text.trim() == '' || lastNameTEController.text.trim() == '') {
        ToastManager.show(
          message: 'Please enter a character',
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
        );
        return;
      }
      loader.value = true;
      final NetworkResponse response = await NetworkCaller().postFormData(
        AppUrl.signUp,
        formData: formData,
      );
      LoggerUtils.debug(response.jsonResponse);
      if (response.isSuccess) {
        if (response.jsonResponse?['status'] == 200) {
          ToastManager.show(
            message: response.jsonResponse?['message'] ?? 'Registration Successful',
          );
          GetStorageModel().saveString(AppConstants.token, response.jsonResponse?['token'] ?? '');
          clearFields();
          Get.offAllNamed(AppRoutes.mainBottomScreen);
        } else if (response.jsonResponse?['status'] == 422) {
          ToastManager.show(
            backgroundColor: AppColors.darkRed,
            textColor: AppColors.white,
            icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
            message: response.jsonResponse?['data']['last_name'][0] ?? 'Registration Successfull',
          );
        } else {
          ToastManager.show(
            backgroundColor: AppColors.darkRed,
            textColor: AppColors.white,
            message: response.jsonResponse?['message'] ?? 'Error Occurred',
          );
        }
      } else {
        ToastManager.show(
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
          message: response.jsonResponse?['message'] ?? 'Error Occurred',
        );
      }
    } catch (e) {
      LoggerUtils.error('Error Encountered $e');
      ToastManager.show(
        message: 'Error $e',
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.textWhite,
      );
    } finally {
      loader.value = false;
    }
  }

  void clearFields() {
    userNameTEController.clear();
    firstNameTEController.clear();
    lastNameTEController.clear();
    passwordTEController.clear();
    confirmPasswordTEController.clear();
  }

  @override
  void dispose() {
    userNameTEController.dispose();
    firstNameTEController.dispose();
    lastNameTEController.dispose();
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    super.dispose();
  }
}
