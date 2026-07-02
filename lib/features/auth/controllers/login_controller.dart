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
  RxBool isLoading = false.obs;

  /// Step 1 - email/phone entry
  final TextEditingController emailPhoneTEController = TextEditingController();
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();

  /// Step 2 - password entry
  final TextEditingController passwordTEController = TextEditingController();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  String get maskedIdentifier {
    final String value = emailPhoneTEController.text.trim();
    final int atIndex = value.indexOf('@');
    if (atIndex <= 0) {
      return value;
    }
    final String local = value.substring(0, atIndex);
    final String domain = value.substring(atIndex);
    final int visible = local.length <= 4 ? 1 : local.length - 4;
    return '${local.substring(0, visible)}****$domain';
  }

  Future<void> handleLogin() async {
    try {
      if (!passwordFormKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;
      final NetworkResponse response = await NetworkCaller().postFormData(
        AppUrl.login,
        formData: <String, String>{
          'email': emailPhoneTEController.text.trim(),
          'password': passwordTEController.text,
        },
        isLogin: true,
      );
      if (response.isSuccess) {
        await GetStorageModel().save(AppConstants.token, response.jsonResponse?['token'] ?? '');
        clearFields();
        ToastManager.show(
          icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
          message: 'Login Successful',
        );
        Get.offAllNamed(AppRoutes.mainBottomScreen);
      } else {
        ToastManager.show(
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
          message: response.jsonResponse?['message'] ?? 'Incorrect email/phone or password',
        );
        passwordTEController.clear();
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
    emailPhoneTEController.clear();
    passwordTEController.clear();
  }

  @override
  void dispose() {
    emailPhoneTEController.dispose();
    passwordTEController.dispose();
    super.dispose();
  }
}