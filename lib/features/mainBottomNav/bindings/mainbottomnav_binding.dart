import 'package:get/get.dart';
import '../controllers/main_bottom_nav_controller.dart';

class MainBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainBottomNavController>(
      () => MainBottomNavController()
    );
  }
}
