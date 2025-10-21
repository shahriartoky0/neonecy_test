// lib/features/wallet/controllers/wallet_controller.dart
import 'package:get/get.dart';

import '../../../core/utils/coin_market_service.dart';
import '../../assets/model/coin_model.dart';
 import '../models/coin_wallet_model.dart';
 import '../wallet_service.dart';

class WalletController extends GetxController {
  final WalletService _walletService = WalletService();
  final CoinMarketCapService _coinMarketCapService = CoinMarketCapService();

  // Reactive list of wallet coins
  final RxList<WalletCoinModel> walletCoins = <WalletCoinModel>[].obs;

  // Total wallet valuation based on user's input USD value
  final RxDouble totalValuation = 0.0.obs;

  // Available coins for selection
  final RxList<CoinItem> availableCoins = <CoinItem>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletCoins();
    fetchAvailableCoins();
  }

  // Fetch wallet coins with market data
  Future<void> fetchWalletCoins() async {
    try {
      isLoading.value = true;

      // Fetch coins and sort
      final coins = await _walletService.getAllWalletCoins();

      // Sort coins: priority coins first, then by market cap
      coins.sort((a, b) {
        final priorityA = _walletService.priorityCoins.indexOf(a.coinDetails.symbol);
        final priorityB = _walletService.priorityCoins.indexOf(b.coinDetails.symbol);

        if (priorityA != -1 && priorityB == -1) return -1;
        if (priorityA == -1 && priorityB != -1) return 1;
        if (priorityA != -1 && priorityB != -1) {
          return priorityA.compareTo(priorityB);
        }

        return int.parse(b.coinDetails.marketCapRank.toString())
            .compareTo(int.parse(a.coinDetails.marketCapRank.toString()));
      });

      walletCoins.value = coins;

      // Calculate total valuation based on user's input USD value
      calculateTotalValuation();
    } catch (e) {
      print('Error fetching wallet coins: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate total valuation based on user's input USD value
  void calculateTotalValuation() {
    // Sum of (quantity * current market price)
    totalValuation.value = walletCoins.fold(
        0.0,
            (total, coin) => total + (coin.quantity * coin.coinDetails.price)
    );
  }

  // Fetch available coins for selection
  Future<void> fetchAvailableCoins() async {
    try {
      isLoading.value = true;

      // Fetch latest listings
      final response = await _coinMarketCapService.getLatestListings(
          limit: 250, // Adjust as needed
          sort: 'market_cap',
          sortDir: 'desc'
      );

      if (response.isSuccess && response.jsonResponse?['data'] != null) {
        final coinList = (response.jsonResponse!['data'] as List)
            .map((coinData) => CoinItem.fromCoinMarketCap(coinData))
            .toList();

        availableCoins.value = coinList;
      }
    } catch (e) {
      print('Error fetching available coins: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add or update a coin in the wallet
  Future<bool> addCoinToWallet({
    required CoinItem coin,
    required double quantity,
    required double averagePurchasePrice,
  }) async {
    try {
      final walletCoin = WalletCoinModel(
          coinDetails: coin,
          quantity: quantity,
          averagePurchasePrice: averagePurchasePrice
      );

      final result = await _walletService.addCoinToWallet(walletCoin);

      if (result) {
        await fetchWalletCoins(); // Refresh wallet
      }

      return result;
    } catch (e) {
      print('Error adding coin to wallet: $e');
      return false;
    }
  }

  // Remove a coin from the wallet
  Future<bool> removeCoinFromWallet(String symbol) async {
    try {
      final result = await _walletService.removeCoinFromWallet(symbol);

      if (result) {
        await fetchWalletCoins(); // Refresh wallet
      }

      return result;
    } catch (e) {
      print('Error removing coin from wallet: $e');
      return false;
    }
  }

  // Update existing wallet coin
  Future<bool> updateWalletCoin({
    required String symbol,
    double? newQuantity,
    double? newAveragePurchasePrice,
  }) async {
    try {
      // Find the existing coin
      final existingCoin = walletCoins.firstWhere(
              (coin) => coin.coinDetails.symbol == symbol
      );

      // Create updated coin model
      final updatedCoin = existingCoin.updateCoin(
          newQuantity: newQuantity,
          newAveragePurchasePrice: newAveragePurchasePrice
      );

      // Save to wallet
      final result = await _walletService.addCoinToWallet(updatedCoin);

      if (result) {
        await fetchWalletCoins(); // Refresh wallet
      }

      return result;
    } catch (e) {
      print('Error updating wallet coin: $e');
      return false;
    }
  }
}