import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';

class SettingsController extends GetxController {
  final RxBool switchValue = false.obs;

  void getSwitchCurrentValue() {
    if (GetStorageModel().exists(AppConstants.switchValue)) {
      switchValue.value = GetStorageModel().read(AppConstants.switchValue);
    } else {
      switchValue.value = false;
    }
  }

  Future<void> toggleSwitch() async {
    switchValue.value = !switchValue.value;
    await GetStorageModel().save(AppConstants.switchValue, switchValue.value);
  }

  @override
  void onInit() {
    getSwitchCurrentValue();
    super.onInit();
  }
}
