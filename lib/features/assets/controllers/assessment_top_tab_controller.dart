import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetTopTabController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ====> For the top tabs ====>
  RxInt selectedTopTab = 0.obs; // 0 for Exchange, 1 for Wallet

  void selectTab(int index) {
    selectedTopTab.value = index;
  }

  bool isExchangeSelected() => selectedTopTab.value == 0;

  bool isWalletSelected() => selectedTopTab.value == 1;

  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> assetTabTitles = <String>['Overview', 'Funding', 'Spot', 'Futures'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: assetTabTitles.length, vsync: this);
    tabController.index = 1;
    // Listen to tab changes
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
