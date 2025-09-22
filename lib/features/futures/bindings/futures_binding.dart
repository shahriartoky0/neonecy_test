import 'package:get/get.dart';
import '../controllers/futures_controller.dart';

class FuturesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FuturesController>(
      () => FuturesController()
    );
  }
}
