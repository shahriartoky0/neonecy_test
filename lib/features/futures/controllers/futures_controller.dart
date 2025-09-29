import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/logger_utils.dart';

class FuturesController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> futureTabTitle = <String>['USD-M', 'COIN-M', 'Options', 'Smart'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: futureTabTitle.length, vsync: this);

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

  /// =========> For the refresh State ============>
  RxBool onRefreshState = false.obs;

  Future<void> onRefresh() async {
    try {
      onRefreshState.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 2000));
    } catch (e) {
      LoggerUtils.error(e);
    } finally {
      onRefreshState.value = false;
    }
  }
}
