import 'package:flutter/cupertino.dart';
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
  final TextEditingController telegramIdTEController = TextEditingController();
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
      final NetworkResponse response = await NetworkCaller().postRequest(
        AppUrl.signUp,
        body: formData,
      );
      LoggerUtils.info(formData);
      LoggerUtils.debug(response.jsonResponse);
      final String message = response.jsonResponse?['message']?.toString() ?? '';
      final Map<String, dynamic>? data = response.jsonResponse?['data'] as Map<String, dynamic>?;
      final Map<String, dynamic>? user = data?['user'] as Map<String, dynamic>?;
      final String? token = data?['token']?.toString();

      if (response.isSuccess) {
        ToastManager.show(
          duration: const Duration(seconds: 4),
          icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
          message: message.isNotEmpty ? message : 'Registration Successful',
        );
        if (token != null && token.isNotEmpty) {
          /// Account is immediately active - log the user straight in.
          await GetStorageModel().save(AppConstants.token, token);
          await GetStorageModel().save(
            AppConstants.lastLoginAt,
            (user?['last_login_at'] as String?) ?? DateTime.now().toIso8601String(),
          );
          final String? email = (user?['email'] ?? formData['email'])?.toString();
          if (email != null && email.isNotEmpty) {
            await GetStorageModel().save(AppConstants.lastLoginEmail, email);
          }
          Get.offAllNamed(AppRoutes.mainBottomScreen);
        } else {
          /// Account created but awaiting admin approval (e.g. status
          /// "not_approved") - send the user to log in once approved.
          Get.offAllNamed(AppRoutes.loginScreen);
        }
        LoggerUtils.debug('Registered user status: ${user?['status']}');
      } else {
        ToastManager.show(
          backgroundColor: AppColors.darkRed,
          textColor: AppColors.white,
          duration: const Duration(seconds: 4),
          message: message.isNotEmpty ? message : 'Registration failed. Please try again.',
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
    telegramIdTEController.dispose();
    super.dispose();
  }
}
