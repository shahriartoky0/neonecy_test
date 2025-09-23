import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetsController extends GetxController   with GetSingleTickerProviderStateMixin{

  /// ====> For the lower tabs
  RxString selectedBottomTab = 'Crypto'.obs;

  void selectBottomTab(String tab) {
    selectedBottomTab.value = tab;
  }

  /// == > for the crypto card
  RxBool isLoadingBottomTab = false.obs;

  void onEarnTap() {
    print('Earn tapped');
    // Add earn functionality
  }

  void onTradeTap() {
    print('Trade tapped');
    // Add trade functionality
  }
}
