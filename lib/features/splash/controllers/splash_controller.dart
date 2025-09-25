import 'package:get/get.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Future<void>.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.loginScreen);
    });
    super.onInit();
  }
}
