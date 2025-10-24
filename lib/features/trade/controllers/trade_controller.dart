// lib/features/trade/controllers/trade_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';
import '../../assets/model/coin_model.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/models/coin_wallet_model.dart';
import '../widgets/conversion_details_screen.dart';

class TradeController extends GetxController with GetSingleTickerProviderStateMixin {
  final WalletController _walletController = Get.find<WalletController>();

  final RxInt selectedOrderType = 0.obs;
  final RxString fromToken = 'Select a Coin'.obs;
  final RxString toToken = 'Select a Coin'.obs;
  final RxString fromAmount = '0'.obs;
  final RxString toAmount = '0'.obs;

  // Selected coin objects
  final Rx<CoinItem?> fromCoin = Rx<CoinItem?>(null);
  final Rx<CoinItem?> toCoin = Rx<CoinItem?>(null);

  // User's actual coin balance from wallet
  final RxDouble fromCoinBalance = 0.0.obs;

  // Available coins in wallet
  RxList<WalletCoinModel> get userWalletCoins => _walletController.walletCoins;

  // Get user's balance for a specific coin
  double getBalanceForCoin(String symbol) {
    final walletCoin = userWalletCoins.firstWhereOrNull(
      (coin) => coin.coinDetails.symbol == symbol,
    );
    return walletCoin?.quantity ?? 0.0;
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

    // Update balance for new from coin
    if (fromCoin.value != null) {
      fromCoinBalance.value = getBalanceForCoin(fromCoin.value!.symbol);
    }

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
    if (fromCoin.value != null) {
      final double maxCoins = getBalanceForCoin(fromCoin.value!.symbol);
      fromAmount.value = formatCoinAmount(maxCoins);
      _updateConversionRate();
    }
  }

  // Method to select from coin
  void selectFromCoin(CoinItem coin) {
    fromCoin.value = coin;
    fromToken.value = coin.symbol;

    // Get actual balance from wallet
    fromCoinBalance.value = getBalanceForCoin(coin.symbol);

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

  // Update conversion rate based on actual coin prices
  void _updateConversionRate() {
    if (fromCoin.value != null &&
        toCoin.value != null &&
        fromAmount.value.isNotEmpty &&
        fromAmount.value != '0') {
      final double fromPrice = fromCoin.value!.price;
      final double toPrice = toCoin.value!.price;
      final double amount = double.tryParse(fromAmount.value) ?? 0;

      if (amount > 0 && fromPrice > 0 && toPrice > 0) {
        // Convert: (amount of from coin × from coin price) ÷ to coin price
        final double fromValueInUSD = amount * fromPrice;
        final double convertedAmount = fromValueInUSD / toPrice;
        toAmount.value = formatCoinAmount(convertedAmount);
      } else {
        toAmount.value = '0';
      }
    } else {
      toAmount.value = '0';
    }
  }

  // Execute the trade
  Future<bool> executeTrade() async {
    if (!validateTrade()) return false;

    try {
      final double fromQty = double.parse(fromAmount.value);
      final double toQty = double.parse(toAmount.value);

      // Remove from coin from wallet
      final fromWalletCoin = userWalletCoins.firstWhere(
        (coin) => coin.coinDetails.symbol == fromCoin.value!.symbol,
      );

      final double newFromBalance = fromWalletCoin.quantity - fromQty;

      if (newFromBalance > 0) {
        // Update the balance
        await _walletController.updateWalletCoin(
          symbol: fromCoin.value!.symbol,
          newQuantity: newFromBalance,
        );
      } else {
        // Remove the coin entirely
        await _walletController.removeCoinFromWallet(fromCoin.value!.symbol);
      }
      if (fromCoin.value != null && toCoin.value != null) {
        Get.to(
          () => ConversionSuccessScreen(
            fromCoin: fromCoin.value!,
            toCoin: toCoin.value!,
            fromAmount: fromAmount.value,
            toAmount: toAmount.value,
          ),
        );
      }
      // Add to coin to wallet
      final existingToCoin = userWalletCoins.firstWhereOrNull(
        (coin) => coin.coinDetails.symbol == toCoin.value!.symbol,
      );

      if (existingToCoin != null) {
        // Update existing coin
        await _walletController.updateWalletCoin(
          symbol: toCoin.value!.symbol,
          newQuantity: existingToCoin.quantity + toQty,
          newAveragePurchasePrice: toCoin.value!.price, // Use current market price
        );
      } else {
        // Add new coin
        await _walletController.addCoinToWallet(
          coin: toCoin.value!,
          quantity: toQty,
          averagePurchasePrice: toCoin.value!.price,
        );
      }

      // // Reset amounts after successful trade
      // fromAmount.value = '0';
      // toAmount.value = '0';

      return true;
    } catch (e) {
      print('Error executing trade: $e');
      return false;
    }
  }

  bool validateTrade() {
    if (fromCoin.value == null || toCoin.value == null) {
      ToastManager.show(message: 'Please select both coins', backgroundColor: AppColors.red);
      return false;
    }

    if (fromCoin.value!.symbol == toCoin.value!.symbol) {
      ToastManager.show(message: 'Cannot convert to the same coin', backgroundColor: AppColors.red);

      return false;
    }

    final double fromQty = double.tryParse(fromAmount.value) ?? 0;
    if (fromQty <= 0) {
      ToastManager.show(message: 'Please enter a valid amount', backgroundColor: AppColors.red);

      return false;
    }

    if (fromQty > getBalanceForCoin(fromCoin.value!.symbol)) {
      ToastManager.show(message: 'Insufficient balance', backgroundColor: AppColors.red);

      return false;
    }

    return true;
  }

  // Format coin amount with appropriate precision
  String formatCoinAmount(double amount) {
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
  RxInt selectedTab = 0.obs;

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

    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
    resetTradeForm();
    // Listen to fromCoin changes
    ever(fromCoin, (CoinItem? coin) {
      if (coin != null) {
        // Update balance when coin is selected
        fromCoinBalance.value = getBalanceForCoin(coin.symbol);
      }
    });

    // Refresh wallet data
    _walletController.fetchWalletCoins();
  }

  void resetTradeForm() {
    // Reset selected tokens
    fromToken.value = 'Select a Coin';
    toToken.value = 'Select a Coin';

    // Reset coin objects
    fromCoin.value = null;
    toCoin.value = null;

    // Reset amounts
    fromAmount.value = '0';
    toAmount.value = '0';

    // Reset balance
    fromCoinBalance.value = 0.0;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
