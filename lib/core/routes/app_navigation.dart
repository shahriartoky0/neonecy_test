import 'package:get/get.dart';
import 'package:neonecy_test/features/auth/bindings/auth_binding.dart';
import 'package:neonecy_test/features/auth/screens/login_screen.dart';
import 'package:neonecy_test/features/auth/screens/sign_up_final_screen.dart';
import 'package:neonecy_test/features/auth/screens/submit_password_screen.dart';
import 'package:neonecy_test/features/home/screens/home_screen.dart';
import 'package:neonecy_test/features/mainBottomNav/bindings/mainbottomnav_binding.dart';
import 'package:neonecy_test/features/mainBottomNav/screens/main_bottom_nav_screen.dart';
import 'package:neonecy_test/features/settings/bindings/settings_binding.dart';
import 'package:neonecy_test/features/settings/controllers/settings_controller.dart';
import 'package:neonecy_test/features/settings/screens/edit_profile_screen.dart';
import 'package:neonecy_test/features/settings/screens/settings_screen.dart';
import 'package:neonecy_test/features/splash/bindings/splash_binding.dart';
import 'package:neonecy_test/features/splash/screens/splash_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import 'app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.firstSplashScreen,
      page: () => const SplashScreen(),
      transition: Transition.noTransition,
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreen(),
      transition: Transition.zoom,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.loginScreen,
      page: () => const LoginScreen(),
      transition: Transition.zoom,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.submitPassword,
      page: () => const SubmitPasswordScreen(),
      transition: Transition.rightToLeft,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.finalSignUp,
      page: () => const SignUpFinalPage(),
      transition: Transition.rightToLeft,
      binding: AuthBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.mainBottomScreen,
      page: () => const MainBottomNavScreen(),
      transition: Transition.upToDown,
      binding: MainBottomNavBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.settingScreen,
      page: () => const SettingsScreen(),
      transition: Transition.leftToRight,
      binding: SettingsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
      binding: SettingsBinding(),
    ),
  ];
}
