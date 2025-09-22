import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketsController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> homeTabTitles = <String>['Favourites', 'Market', 'Alpha', 'Grow', 'Square', 'Database'];

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
