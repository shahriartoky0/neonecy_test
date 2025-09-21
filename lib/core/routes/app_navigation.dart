import 'package:get/get.dart';
import 'package:neonecy_test/features/home/screens/home_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import 'app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreen(),
      transition: Transition.zoom,
      binding: HomeBinding(),
    ),
  ];
}
