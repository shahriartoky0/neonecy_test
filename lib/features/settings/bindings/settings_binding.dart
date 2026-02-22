import 'package:get/get.dart';
import 'package:neonecy_test/features/settings/controllers/change_address_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<ChangeAddressController>(() => ChangeAddressController());
  }
}
