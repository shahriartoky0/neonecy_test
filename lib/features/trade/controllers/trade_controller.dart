import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_constants.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';
import '../../assets/model/coin_model.dart';

class TradeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxInt selectedOrderType = 0.obs;
  final RxString fromToken = 'Select a Coin'.obs;
  final RxString toToken = 'Select a Coin'.obs;
  final RxString fromAmount = '0'.obs;
  final RxString toAmount = '0'.obs;

  // Selected coin objects
  final Rx<CoinItem?> fromCoin = Rx<CoinItem?>(null);
  final Rx<CoinItem?> toCoin = Rx<CoinItem?>(null);

  // User's coin balance for the selected "from" coin
  final RxDouble fromCoinBalance = 0.0.obs;

  // Get user's USD balance from storage
  double get userUSDBalance {
    final String? storedBalance = GetStorageModel().read(AppConstants.balanceText);
    if (storedBalance != null && storedBalance.isNotEmpty) {
      // Remove commas if present and parse
      final String cleanBalance = storedBalance.replaceAll(',', '');
      return double.tryParse(cleanBalance) ?? 0.0;
    }
    return 0.0;
  }

  // Calculate available balance in selected coin
  String get availableInSelectedCoin {
    if (fromCoin.value != null && fromCoin.value!.price > 0) {
      final double coinBalance = userUSDBalance / fromCoin.value!.price;
      return _formatCoinAmount(coinBalance);
    }
    return '0';
  }

  void selectOrderType(int index) {
    selectedOrderType.value = index;
  }

  void swapTokens() {
    // Swap token symbols
    final String tempToken = fromToken.value;
    fromToken.value = toToken.value;
    toToken.value = tempToken;

    // Swap coin objects
    final CoinItem? tempCoin = fromCoin.value;
    fromCoin.value = toCoin.value;
    toCoin.value = tempCoin;

    // Recalculate amounts after swap
    if (fromAmount.value.isNotEmpty && fromAmount.value != '0') {
      _updateConversionRate();
    } else {
      fromAmount.value = '0';
      toAmount.value = '0';
    }
  }

  void updateFromAmount(String value) {
    fromAmount.value = value;
    _updateConversionRate();
  }

  void setMaxAmount() {
    if (fromCoin.value != null && fromCoin.value!.price > 0) {
      // Calculate maximum coins user can have with their USD balance
      final double maxCoins = userUSDBalance / fromCoin.value!.price;
      fromAmount.value = _formatCoinAmount(maxCoins);
      _updateConversionRate();
    }
  }

  // Method to select from coin
  void selectFromCoin(CoinItem coin) {
    fromCoin.value = coin;
    fromToken.value = coin.symbol;

    // Calculate how much of this coin the user can afford
    if (coin.price > 0) {
      fromCoinBalance.value = userUSDBalance / coin.price;
    }

    // Recalculate if amount exists
    if (fromAmount.value.isNotEmpty && fromAmount.value != '0') {
      _updateConversionRate();
    }
  }

  // Method to select to coin
  void selectToCoin(CoinItem coin) {
    toCoin.value = coin;
    toToken.value = coin.symbol;
    // Recalculate if amount exists
    if (fromAmount.value.isNotEmpty && fromAmount.value != '0') {
      _updateConversionRate();
    }
  }

  // Update conversion rate based on actual coin prices from CoinItem
  void _updateConversionRate() {
    if (fromCoin.value != null &&
        toCoin.value != null &&
        fromAmount.value.isNotEmpty &&
        fromAmount.value != '0') {

      // Get the actual prices from the coin objects
      final double fromPrice = fromCoin.value!.price;
      final double toPrice = toCoin.value!.price;
      final double amount = double.tryParse(fromAmount.value) ?? 0;

      if (amount > 0 && fromPrice > 0 && toPrice > 0) {
        // Convert: (amount of from coin × from coin price) ÷ to coin price
        final double fromValueInUSD = amount * fromPrice;
        final double convertedAmount = fromValueInUSD / toPrice;
        toAmount.value = _formatCoinAmount(convertedAmount);
      } else {
        toAmount.value = '0';
      }
    } else {
      toAmount.value = '0';
    }
  }

  // Get USD value of "from" amount
  double get fromAmountInUSD {
    if (fromCoin.value != null && fromAmount.value.isNotEmpty && fromAmount.value != '0') {
      final double amount = double.tryParse(fromAmount.value) ?? 0;
      return amount * fromCoin.value!.price;
    }
    return 0.0;
  }

  // Get USD value of "to" amount
  double get toAmountInUSD {
    if (toCoin.value != null && toAmount.value.isNotEmpty && toAmount.value != '0') {
      final double amount = double.tryParse(toAmount.value) ?? 0;
      return amount * toCoin.value!.price;
    }
    return 0.0;
  }

  // Format coin amount with appropriate precision
  String _formatCoinAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount >= 1) {
      return amount.toStringAsFixed(4);
    } else if (amount >= 0.0001) {
      return amount.toStringAsFixed(6);
    } else if (amount > 0) {
      return amount.toStringAsFixed(8);
    }
    return '0';
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
    // Listen to fromCoin changes and auto-fill max amount
    ever(fromCoin, (CoinItem? coin) {
      if (coin != null) {
        // Automatically set max amount when from coin is selected
        setMaxAmount();
      }
    });
  }

  /// ===========> For the balance =====>
  final TextEditingController balanceTEController = TextEditingController();

  void saveTheBalance() {
    if (balanceTEController.text.isNotEmpty) {
      GetStorageModel().save(AppConstants.balanceText, balanceTEController.text);
      // Reset amounts when balance changes
      fromAmount.value = '0';
      toAmount.value = '0';
      update(); // Trigger UI update
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}