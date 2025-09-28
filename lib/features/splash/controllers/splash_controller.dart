import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';

import '../../../core/utils/logger_utils.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Future<void>.delayed(const Duration(seconds: 2), () {
      // LoggerUtils.debug('The token exists : ${GetStorageModel().exists(AppConstants.token)}');
      if (GetStorageModel().exists(AppConstants.token)) {
        Get.offAllNamed(AppRoutes.mainBottomScreen);
      } else {
        Get.offAllNamed(AppRoutes.loginScreen);
      }
    });
    super.onInit();
  }
}
