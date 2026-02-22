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

  // Total wallet valuation based on current market prices
  final RxDouble totalValuation = 0.0.obs;

  // Total invested amount
  final RxDouble totalInvested = 0.0.obs;

  // Total profit/loss
  final RxDouble totalProfitLoss = 0.0.obs;

  // Total profit/loss percentage
  final RxDouble totalProfitLossPercent = 0.0.obs;

  // Available coins for selection
  final RxList<CoinItem> availableCoins = <CoinItem>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 WalletController initialized');
    fetchWalletCoins();
    fetchAvailableCoins();
  }

  // Fetch wallet coins with market data
  Future<void> fetchWalletCoins() async {
    try {
      print('📥 Fetching wallet coins...');
      isLoading.value = true;

      // Fetch coins with updated market data
      final coins = await _walletService.getAllWalletCoins();
      print('✅ Fetched ${coins.length} coins from service');

      // Sort coins: priority coins first, then by market cap
      coins.sort((a, b) {
        final priorityA = _walletService.priorityCoins.indexOf(a.coinDetails.symbol);
        final priorityB = _walletService.priorityCoins.indexOf(b.coinDetails.symbol);

        if (priorityA != -1 && priorityB == -1) return -1;
        if (priorityA == -1 && priorityB != -1) return 1;
        if (priorityA != -1 && priorityB != -1) {
          return priorityA.compareTo(priorityB);
        }

        // Sort by market cap rank (lower rank = higher position)
        return a.coinDetails.marketCapRank.compareTo(b.coinDetails.marketCapRank);
      });

      // Update the observable list
      walletCoins.value = coins;
      print('🔄 Updated walletCoins observable with ${walletCoins.length} coins');

      // Force a rebuild
      walletCoins.refresh();
      print('🔃 Refreshed observable');

      // Calculate valuations
      calculateTotalValuation();
      calculateProfitLoss();

      print('💰 Total valuation: \$${totalValuation.value.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error fetching wallet coins: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate total valuation based on current market prices
  void calculateTotalValuation() {
    totalValuation.value = walletCoins.fold(
      0.0,
          (total, coin) => total + (coin.quantity * coin.coinDetails.price),
    );
  }

  // Calculate total invested amount
  void calculateTotalInvested() {
    totalInvested.value = walletCoins.fold(
      0.0,
          (total, coin) => total + (coin.quantity * coin.averagePurchasePrice),
    );
  }

  // Calculate profit/loss
  void calculateProfitLoss() {
    calculateTotalInvested();
    totalProfitLoss.value = totalValuation.value - totalInvested.value;

    if (totalInvested.value > 0) {
      totalProfitLossPercent.value =
          (totalProfitLoss.value / totalInvested.value) * 100;
    } else {
      totalProfitLossPercent.value = 0.0;
    }
  }

  // Fetch available coins for selection
  Future<void> fetchAvailableCoins() async {
    try {
      print('📊 Fetching available coins...');

      // Fetch latest listings
      final response = await _coinMarketCapService.getLatestListings(
        limit: 250,
        sort: 'market_cap',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse?['data'] != null) {
        // Get BTC price for calculations
        final btcData = (response.jsonResponse!['data'] as List).firstWhere(
              (coin) => coin['symbol'] == 'BTC',
          orElse: () => null,
        );

        final double btcPrice = btcData != null
            ? (btcData['quote']['USD']['price'] as num).toDouble()
            : 65000.0; // Fallback BTC price

        final coinList = (response.jsonResponse!['data'] as List)
            .map((coinData) => CoinItem.fromCoinMarketCap(coinData, btcPrice: btcPrice))
            .toList();

        availableCoins.value = coinList;
        print('✅ Loaded ${availableCoins.length} available coins');
      } else {
        print('❌ Failed to fetch available coins');
      }
    } catch (e) {
      print('❌ Error fetching available coins: $e');
    }
  }

  // Add or update a coin in the wallet
  Future<bool> addCoinToWallet({
    required CoinItem coin,
    required double quantity,
    required double averagePurchasePrice,
  }) async {
    try {
      print('➕ Adding ${coin.symbol} to wallet...');
      print('   Quantity: $quantity');
      print('   Purchase Price: \$${averagePurchasePrice.toStringAsFixed(2)}');

      final walletCoin = WalletCoinModel(
        coinDetails: coin,
        quantity: quantity,
        averagePurchasePrice: averagePurchasePrice,
      );

      final result = await _walletService.addCoinToWallet(walletCoin);
      print('💾 Save result: $result');

      if (result) {
        print('🔄 Refreshing wallet after add...');
        await fetchWalletCoins();
        print('✅ Wallet refreshed successfully');
        print('📊 Current wallet has ${walletCoins.length} coins');
      } else {
        print('❌ Failed to save coin to wallet');
      }

      return result;
    } catch (e) {
      print('❌ Error adding coin to wallet: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Remove a coin from the wallet
  Future<bool> removeCoinFromWallet(String symbol) async {
    try {
      print('➖ Removing $symbol from wallet...');

      final result = await _walletService.removeCoinFromWallet(symbol);
      print('💾 Remove result: $result');

      if (result) {
        print('🔄 Refreshing wallet after remove...');
        await fetchWalletCoins();
        print('✅ Wallet refreshed successfully');
      } else {
        print('❌ Failed to remove coin from wallet');
      }

      return result;
    } catch (e) {
      print('❌ Error removing coin from wallet: $e');
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
      print('✏️ Updating $symbol in wallet...');

      // Find the existing coin
      final existingCoin = walletCoins.firstWhere(
            (coin) => coin.coinDetails.symbol == symbol,
      );

      print('   Old quantity: ${existingCoin.quantity}');
      print('   New quantity: $newQuantity');
      print('   Old price: \$${existingCoin.averagePurchasePrice.toStringAsFixed(2)}');
      print('   New price: \$${newAveragePurchasePrice?.toStringAsFixed(2)}');

      // Create updated coin model
      final updatedCoin = existingCoin.updateCoin(
        newQuantity: newQuantity,
        newAveragePurchasePrice: newAveragePurchasePrice,
      );

      // Save to wallet
      final result = await _walletService.addCoinToWallet(updatedCoin);
      print('💾 Update result: $result');

      if (result) {
        print('🔄 Refreshing wallet after update...');
        await fetchWalletCoins();
        print('✅ Wallet refreshed successfully');
      } else {
        print('❌ Failed to update coin in wallet');
      }

      return result;
    } catch (e) {
      print('❌ Error updating wallet coin: $e');
      return false;
    }
  }
  /// Withdraw coin - reduces the quantity in wallet
  Future<void> withdrawCoin({
    required String coinSymbol,
    required double amount,
  }) async {
    try {
      // Find the coin in wallet
      final int index = walletCoins.indexWhere(
            (WalletCoinModel coin) => coin.coinDetails.symbol.toUpperCase() == coinSymbol.toUpperCase(),
      );

      if (index == -1) {
        throw Exception('Coin $coinSymbol not found in wallet');
      }

      final WalletCoinModel currentCoin = walletCoins[index];

      // Validate amount
      if (amount > currentCoin.quantity) {
        throw Exception('Insufficient balance');
      }

      if (amount <= 0) {
        throw Exception('Invalid amount');
      }

      // Calculate new quantity
      final double newQuantity = currentCoin.quantity - amount;

      if (newQuantity <= 0) {
        // Remove coin entirely if balance becomes 0
        walletCoins.removeAt(index);
        print('🗑️ Removed $coinSymbol from wallet (balance = 0)');
      } else {
        // Update coin with new quantity
        final WalletCoinModel updatedCoin = currentCoin.copyWith(quantity: newQuantity);
        walletCoins[index] = updatedCoin;
        print('📤 Withdrawn $amount $coinSymbol. New balance: $newQuantity');
      }

      // Save to storage
      // await _saveWalletToStorage();

      print('✅ Withdraw successful: $amount $coinSymbol');
    } catch (e) {
      print('❌ Withdraw error: $e');
      rethrow;
    }
  }
}