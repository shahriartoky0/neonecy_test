import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';

import '../../../core/utils/coin_gecko.dart';
import '../../../core/utils/logger_utils.dart';
import 'crypto_market_controller.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the top Buttons =====>
  RxInt selectedTab = 0.obs;
  RxBool showSpace = false.obs;

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


    /// ==============> for the tabs ==========>
    tabController = TabController(length: homeTabTitles.length, vsync: this);

    // Listen to tab changes
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
    //// ========for balance ======>
    fetchAndSetTheBalance();
    // GetStorageModel().delete(AppConstants.balanceText);
  }

  Future<void> onRefresh() async {
    showSpace.value = true;
    LoggerUtils.debug("Refreshing...${showSpace.value}"); // Debug
    // Add your refresh logic here
    for (int i = 0; i < 8; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    showSpace.value = false;
    LoggerUtils.debug("Refresh completed ${showSpace.value}");

    /// =====> for the balance =====>
    fetchAndSetTheBalance();

    /// =====> for the hintText =====>
    hintText.value = _generateRandomHint();

    /// ====== for the refresh ====>
    final CryptoMarketController cryptoMarketController = Get.put(CryptoMarketController());
    cryptoMarketController.refreshCurrentTab();
  }

  /// ==========> For app hint text ====>
  final RxString hintText = '#BinanceHODLerPLUME'.obs;

  /// ==========> For the balance ======>
  final RxString balance = '0.00'.obs;

  void fetchAndSetTheBalance() {
    final bool isBalanceStored = GetStorageModel().exists(AppConstants.balanceText);
    if (isBalanceStored) {
      balance.value = GetStorageModel().read(AppConstants.balanceText);
    } else {
      balance.value = '0.00';
    }
  }

  /// =========> for randomly generated hint texts ===========>
  // List of possible hint texts
  final List<String> hintOptions = <String>[
    '#BinanceHODLerPLUME',
    '#CryptoRisingStar',
    '#BitcoinToTheMoon',
    '#EthereumForTheWin',
    '#AltcoinsRock',
    '#FutureOfFinance',
  ];

  // Randomly generate hint text
  String _generateRandomHint() {
    final Random random = Random();
    final int randomIndex = random.nextInt(hintOptions.length);
    return hintOptions[randomIndex];
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
