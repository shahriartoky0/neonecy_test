import 'package:get/get.dart';
import 'package:neonecy_test/features/markets/widget/enhanced_crupto.dart';
import '../controllers/markets_controller.dart';

class MarketsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketsController>(() => MarketsController());
   }
}
