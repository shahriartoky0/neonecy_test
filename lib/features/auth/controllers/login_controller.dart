import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
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

      final String identifier = emailPhoneTEController.text.trim();
      final Map<String, dynamic> loginBody = <String, dynamic>{
        'email_or_phone': identifier,
        'password': passwordTEController.text,
        'device_name': await DeviceUtility.getDeviceName(),
        'device_type': DeviceUtility.getDeviceType(),
      };

      final NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.login,
        body: loginBody,
        isLogin: true,
      );

      final Map<String, dynamic>? data = response.jsonResponse?['data'] as Map<String, dynamic>?;
      final Map<String, dynamic>? user = data?['user'] as Map<String, dynamic>?;
      final String? status = (user?['status'] ?? response.jsonResponse?['status'])?.toString();
      final String message = response.jsonResponse?['message']?.toString() ?? '';
      final String? token = data?['token']?.toString();

      if (response.isSuccess && token != null && token.isNotEmpty) {
        await GetStorageModel().save(AppConstants.token, token);
        await GetStorageModel().save(
          AppConstants.lastLoginAt,
          (user?['last_login_at'] as String?) ?? DateTime.now().toIso8601String(),
        );
        await GetStorageModel().save(AppConstants.lastLoginEmail, identifier);
        clearFields();
        ToastManager.show(
          icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
          message: message.isNotEmpty ? message : 'Login Successful',
        );
        Get.offAllNamed(AppRoutes.mainBottomScreen);
      } else if (status == 'not_approved') {
        ToastManager.show(
          backgroundColor: AppColors.orange,
          textColor: AppColors.white,
          message: message.isNotEmpty ? message : 'Your account is pending approval.',
        );
      } else {
        ToastManager.show(
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
          message: message.isNotEmpty ? message : 'Incorrect email/phone or password',
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
      GetStorageModel().delete(AppConstants.lastLoginAt);
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
