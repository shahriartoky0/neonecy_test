import 'package:get/get.dart';

class AuthController extends GetxController {
  RxInt selectedTab = 0.obs;

  void selectTab(int index) {
    selectedTab.value = index;
  }

  bool isLoginTabSelected() => selectedTab.value == 0;

  bool isSignUpTabSelected() => selectedTab.value == 1;


}
