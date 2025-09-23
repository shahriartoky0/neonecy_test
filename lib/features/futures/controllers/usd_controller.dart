import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsdController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> usdTabTitle = <String>['Positions (0)', 'Open Orders (0)', 'Futures Grid', 'Smart'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: usdTabTitle.length, vsync: this);

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
