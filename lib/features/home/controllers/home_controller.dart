import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';
import 'package:neonecy_test/features/wallet/controllers/wallet_controller.dart';

import '../../../core/utils/logger_utils.dart';
import '../models/mock_post_model.dart';
import 'crypto_market_controller.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ===> For the Random Messages  =====>
  final RxInt messageCount = Random().nextInt(100).obs + 1;
  Timer? _messageTimer;

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

  /// ===> Mock posts for Discover tab =====>
  final RxList<MockPost> displayedPosts = <MockPost>[].obs;

  /// ===> Floating button visibility =====>
  final RxBool showFloatingPlus = false.obs;
  final RxBool showFloatingAi = true.obs;

  void onDiscoverScroll(double offset) {
    final bool inPosts = offset > 180;
    showFloatingPlus.value = inPosts;
    showFloatingAi.value = !inPosts;
  }

  void randomizePosts() {
    final List<MockPost> shuffled = List<MockPost>.from(kMockPosts)..shuffle(Random());
    displayedPosts.value = shuffled.take(5).toList();
  }

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: homeTabTitles.length, vsync: this);
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
      if (tabController.index != 0) {
        showFloatingPlus.value = false;
        showFloatingAi.value = true;
      }
    });

    fetchAndSetTheBalance();
    randomizePosts();

    _messageTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      messageCount.value = Random().nextInt(100) + 1;
    });
  }

  Future<void> onRefresh() async {
    showSpace.value = true;
    LoggerUtils.debug('Refreshing...${showSpace.value}');
    for (int i = 0; i < 8; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    showSpace.value = false;
    LoggerUtils.debug('Refresh completed ${showSpace.value}');

    fetchAndSetTheBalance();
    hintText.value = _generateRandomHint();
    randomizePosts();

    final CryptoMarketController cryptoMarketController = Get.put(CryptoMarketController());
    await cryptoMarketController.refreshCurrentTab();
  }

  /// ==========> For app hint text ====>
  final RxString hintText = '#BinanceHODLerPLUME'.obs;

  /// ==========> For the balance ======>
  final RxString balance = '0.00'.obs;

  final WalletController _walletController = Get.find<WalletController>();

  void fetchAndSetTheBalance() {
    try {
      final double totalBalance = _calculateTotalWalletBalance();
      GetStorageModel().save(AppConstants.balanceText, totalBalance.toStringAsFixed(3));
      balance.value = totalBalance.toStringAsFixed(2);
    } catch (e) {
      final bool isBalanceStored = GetStorageModel().exists(AppConstants.balanceText);
      if (isBalanceStored) {
        balance.value = GetStorageModel().read(AppConstants.balanceText);
      } else {
        balance.value = '0.00';
      }
      LoggerUtils.debug('Error fetching wallet balance: $e');
    }
  }

  double _calculateTotalWalletBalance() {
    return Get.find<WalletController>().totalValuation.value;
  }

  WalletController get walletController => _walletController;

  final List<String> hintOptions = <String>[
    '#BinanceHODLerPLUME',
    '#CryptoRisingStar',
    '#BitcoinToTheMoon',
    '#EthereumForTheWin',
    '#AltcoinsRock',
    '#FutureOfFinance',
  ];

  String _generateRandomHint() {
    return hintOptions[Random().nextInt(hintOptions.length)];
  }

  @override
  void onClose() {
    tabController.dispose();
    _messageTimer?.cancel();
    super.onClose();
  }
}