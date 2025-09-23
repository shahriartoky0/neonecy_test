import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the top Buttons =====>
  RxInt selectedTab = 0.obs; // 0 for Exchange, 1 for Wallet

  void selectTab(int index) {
    selectedTab.value = index;
  }

  bool isExchangeSelected() => selectedTab.value == 0;

  bool isWalletSelected() => selectedTab.value == 1;

  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> homeTabTitles = <String>[
    'Discover',
    'Following',
    'Campaign',
    'News',
    'Announcement',
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: homeTabTitles.length, vsync: this);

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
