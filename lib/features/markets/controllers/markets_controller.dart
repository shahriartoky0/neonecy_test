import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/logger_utils.dart';

class MarketsController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> homeTabTitles = <String>[
    'Favourites',
    'Market',
    'Alpha',
    'Grow',
    'Square',
    'Database',
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

  /// ==== for the refresh ============>
  final RxBool onRefreshState = false.obs;

  Future<void> onRefresh() async {
    onRefreshState.value = true;
    LoggerUtils.debug("Refreshing...${onRefreshState.value}"); // Debug

    await Future.delayed(const Duration(milliseconds: 1600));

    onRefreshState.value = false;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
