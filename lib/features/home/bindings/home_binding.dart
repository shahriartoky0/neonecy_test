import 'package:get/get.dart';
import 'package:neonecy_test/features/home/controllers/crypto_market_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CryptoMarketController>(() => CryptoMarketController());
  }
}
