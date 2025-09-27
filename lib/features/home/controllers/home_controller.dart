import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/logger_utils.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the top Buttons =====>
  RxInt selectedTab = 0.obs;
  RxBool showSpace = false.obs;
  RxDouble blurEffectSize = 20.0.obs;

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

  Future<void> onRefresh() async {

    showSpace.value = true;
    LoggerUtils.debug("Refreshing...${showSpace.value}"); // Debug
    // Add your refresh logic here
    for(int i = 0; i < 8; i++){
      blurEffectSize.value += 20;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    showSpace.value = false;
    blurEffectSize.value = 20;
    LoggerUtils.debug("Refresh completed ${showSpace.value}");
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
