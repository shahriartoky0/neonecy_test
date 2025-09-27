import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';

import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/config/app_url.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/network/network_caller.dart';
import '../../../core/network/network_response.dart';

class LoginController extends GetxController {
  ///=====> For login text form controller =====>
  RxBool isLoading = false.obs;

  final TextEditingController userNameTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// =======> handle the logic of login ===========>
  Future<void> handleLogin() async {
    try {
      if (!loginFormKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      final NetworkResponse response = await NetworkCaller().postFormData(
        AppUrl.login,
        formData: <String, String>{
          'user_name': userNameTEController.text,
          'password': passwordTEController.text,
        },
      );
      if (response.isSuccess) {
        if (response.jsonResponse?['status'] == 422) {
          ToastManager.show(
            backgroundColor: AppColors.darkRed,
            textColor: AppColors.white,
            message: response.jsonResponse?['message'] ?? 'Incorrect username or password !!',
          );
          passwordTEController.clear();
        }
        /// ===========> Successful Login =============>
        ///
        else if (response.jsonResponse?['success'] == 200) {
          GetStorageModel().saveString(AppConstants.token, response.jsonResponse?['token'] ?? '');
         clearFields();
          ToastManager.show(
            icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
            message: 'Login Successful',
          );
          Get.offAllNamed(AppRoutes.mainBottomScreen);
        }
      } else {
        ToastManager.show(
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
          message: response.jsonResponse?['message'] ?? 'Error Occurred. Please try again !!',
        );
      }
    } catch (e) {
      LoggerUtils.error("Error is $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logOut() async {
    try {
      isLoading.value = true;
      // final NetworkResponse response = await NetworkCaller().postFormData(
      //   AppUrl.login,
      //   formData: <String, String>{
      //     'user_name': userNameTEController.text,
      //     'password': passwordTEController.text,
      //   },
      // );
      GetStorageModel().delete(AppConstants.token);
      ToastManager.show(message: 'Logout Successful');
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (e) {
      LoggerUtils.error("Error is $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    userNameTEController.clear();
    passwordTEController.clear();
  }

  @override
  void dispose() {
    userNameTEController.dispose();
    passwordTEController.dispose();
    super.dispose();
  }
}
