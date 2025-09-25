import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';

class LoginController extends GetxController {
  ///=====> For login text form controller =====>
  RxBool isLoading = false.obs;

  final TextEditingController userNameTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

  /// =======> handle the logic of login ===========>
  Future<void> handleLogin() async {
    try {
      isLoading.value = true;
      await Future<void>.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.mainBottomScreen);
    } catch (e) {
      LoggerUtils.error("Error is $e");
    } finally {
      isLoading.value = false;
    }
  }
}
