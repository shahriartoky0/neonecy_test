import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/features/auth/screens/login_screen.dart';
import 'package:neonecy_test/features/futures/controllers/futures_controller.dart';
 import 'package:neonecy_test/features/futures/screens/futures_screen.dart';
import 'package:neonecy_test/features/home/controllers/crypto_market_controller.dart';
import 'package:neonecy_test/features/home/controllers/home_controller.dart';
import 'package:neonecy_test/features/mainBottomNav/controllers/main_bottom_nav_controller.dart';
import 'package:neonecy_test/features/mainBottomNav/screens/main_bottom_nav_screen.dart';
import 'package:neonecy_test/features/markets/controllers/markets_controller.dart';
import 'package:neonecy_test/features/trade/controllers/trade_controller.dart';
import 'core/design/app_theme.dart';
import 'core/routes/app_navigation.dart';
import 'core/routes/app_routes.dart';
import 'features/markets/controllers/enhanced_market_controller.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.defaultThemeData,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.firstSplashScreen,
      getPages: AppNavigation.routes,
      // home: const LoginScreen(),
      initialBinding: ControllerBinder(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ControllerBinder extends Bindings {
  /// GLOBAL controller ====>
  @override
  void dependencies() {
    Get.put(MainBottomNavController());
    Get.put(HomeController());
    Get.put(CryptoMarketController());
    Get.put(MarketsController());
    Get.put(EnhancedCryptoMarketController());
    Get.put(TradeController());
    Get.put(FuturesController());
   }
}
