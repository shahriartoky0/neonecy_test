import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';

class TradeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxInt selectedOrderType = 0.obs;
  final RxString fromToken = 'PEPE'.obs;
  final RxString toToken = 'PLUME'.obs;
  final RxString fromAmount = '950'.obs;
  final RxString toAmount = '0.12'.obs;
  final RxString availableBalance = '20,000'.obs;
  final RxString maxFromRange = '96000000'.obs;
  final RxString maxToRange = '1200000'.obs;

  void selectOrderType(int index) {
    selectedOrderType.value = index;
  }

  void swapTokens() {
    final String tempToken = fromToken.value;
    final String tempAmount = fromAmount.value;
    final String tempRange = maxFromRange.value;

    fromToken.value = toToken.value;
    fromAmount.value = toAmount.value;
    maxFromRange.value = maxToRange.value;

    toToken.value = tempToken;
    toAmount.value = tempAmount;
    maxToRange.value = tempRange;
  }

  void updateFromAmount(String value) {
    fromAmount.value = value;
    if (value.isNotEmpty) {
      final double amount = double.tryParse(value) ?? 0;
      const double rate = 0.000126;
      toAmount.value = (amount * rate).toStringAsFixed(8);
    }
  }

  void setMaxAmount() {
    fromAmount.value = availableBalance.value.replaceAll(',', '');
    updateFromAmount(fromAmount.value);
  }

  /// ============> For the top tab bar =====>
  RxInt selectedTab = 0.obs; // 0 for Exchange, 1 for Wallet

  void selectTab(int index) {
    selectedTab.value = index;
  }

  bool isExchangeSelected() => selectedTab.value == 0;

  bool isWalletSelected() => selectedTab.value == 1;

  /// ===> For the Tab options =====>
  late TabController tabController;
  RxInt selectedIndex = 0.obs;

  final List<String> homeTabTitles = <String>['Convert', 'Sport', 'Margin', 'Buy/Sell', 'P2'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: homeTabTitles.length, vsync: this);

    // Listen to tab changes
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
  }

  /// ===========> For the balance =====>
  final TextEditingController balanceTEController = TextEditingController();

  void saveTheBalance() {
    GetStorageModel().save(AppConstants.balanceText, balanceTEController.text);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
/// ======> neonecy completed