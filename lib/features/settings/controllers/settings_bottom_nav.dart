import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import 'package:neonecy_test/features/home/screens/home_screen.dart';
import 'package:neonecy_test/features/markets/screens/markets_screen.dart';
import 'package:neonecy_test/features/settings/screens/settings_screen.dart';
import '../../../core/design/app_icons.dart';
import '../../assets/screens/assets_screen.dart';
import '../../futures/screens/futures_screen.dart';
import '../../trade/screens/trade_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../screens/edit_profile_screen.dart';

class SettingsBottomNavController extends GetxController {
  // Reactive selected index
  final RxInt _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  // PageController
  late final PageController pageController;

  // Static data
  final List<Widget> screens = <Widget>[const SettingsScreen(), WalletView()];

  final List<String> icons = <String>[AppIcons.navHome, AppIcons.navAsset];

  final List<String> labels = <String>['Home', 'Wallet'];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }


  @override
  void onClose() {
    _selectedIndex.value = 0;  // Reset the index
    pageController.jumpToPage(0); // Jump to the first page
    pageController.dispose();
    super.onClose();
  }

  /// Update selected index when page changes
  void onPageChanged(int index) {
    _selectedIndex.value = index;
  }

  /// Navigate to specific tab
  void navigateToTab(int index) {
    DeviceUtility.hapticFeedback();
    pageController.jumpToPage(index);
    _selectedIndex.value = index;
  }

  /// Check if tab is selected
  bool isTabSelected(int index) {
    return selectedIndex == index;
  }
}
