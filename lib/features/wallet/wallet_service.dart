// lib/features/wallet/wallet_service.dart
import 'package:get_storage/get_storage.dart';

import '../../core/utils/coin_market_service.dart';
import '../../core/utils/get_storage.dart';
import '../assets/model/coin_model.dart';
import 'models/coin_wallet_model.dart';

class WalletService {
  final GetStorageModel _storage = GetStorageModel();
  final CoinMarketCapService _coinMarketCapService = CoinMarketCapService();

  // Priority coins to be shown first
  final List<String> priorityCoins = ['BNB', 'ETH', 'BTC', 'USDT'];

  // Save a coin to wallet
  Future<bool> addCoinToWallet(WalletCoinModel walletCoin) async {
    try {
      print('💾 [Service] Saving ${walletCoin.coinDetails.symbol} to wallet...');

      // Retrieve existing wallet coins (without market data fetch)
      List<WalletCoinModel> existingCoins = await _getStoredWalletCoins();
      print('📦 [Service] Found ${existingCoins.length} existing coins');

      // Check if coin already exists
      final existingCoinIndex = existingCoins.indexWhere(
            (coin) => coin.coinDetails.symbol == walletCoin.coinDetails.symbol,
      );

      if (existingCoinIndex != -1) {
        print('🔄 [Service] Updating existing ${walletCoin.coinDetails.symbol}');
        existingCoins[existingCoinIndex] = walletCoin;
      } else {
        print('➕ [Service] Adding new ${walletCoin.coinDetails.symbol}');
        existingCoins.add(walletCoin);
      }

      // Convert to JSON
      final jsonData = existingCoins.map((coin) => coin.toJson()).toList();
      print('📝 [Service] Prepared ${jsonData.length} coins for storage');

      // Save updated list
      await _storage.save('wallet_coins', jsonData);

      // Verify save
      final savedData = _storage.read('wallet_coins');
      if (savedData != null) {
        print('✅ [Service] Verified: ${(savedData as List).length} coins saved');
        return true;
      } else {
        print('❌ [Service] Verification failed: Data not saved');
        return false;
      }
    } catch (e) {
      print('❌ [Service] Error adding coin to wallet: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Get stored wallet coins without market data update
  Future<List<WalletCoinModel>> _getStoredWalletCoins() async {
    try {
      print('📖 [Service] Reading stored coins...');
      final storedCoins = _storage.read('wallet_coins');

      if (storedCoins == null) {
        print('📭 [Service] No coins stored yet');
        return [];
      }

      final coinList = storedCoins as List;
      if (coinList.isEmpty) {
        print('📭 [Service] Empty coins list');
        return [];
      }

      print('📦 [Service] Found ${coinList.length} stored coins');

      final parsedCoins = coinList.map((coinJson) {
        // Create a minimal CoinItem for storage purposes
        return WalletCoinModel(
          coinDetails: CoinItem(
            id: coinJson['coinId']?.toString() ?? '',
            coinId: coinJson['coinId'] ?? 0,
            name: coinJson['name'] ?? '',
            symbol: coinJson['symbol'] ?? '',
            marketCapRank: coinJson['marketCapRank'] ?? 0,
            thumb: coinJson['thumb'] ?? '',
            small: coinJson['small'] ?? '',
            large: coinJson['large'] ?? '',
            slug: coinJson['slug'] ?? '',
            price: 0.0, // Will be updated from API
            priceBtc: 0.0,
            marketCap: '',
            totalVolume: '',
            sparkline: '',
            percentChange24h: 0.0,
          ),
          quantity: (coinJson['quantity'] as num?)?.toDouble() ?? 0.0,
          averagePurchasePrice: (coinJson['averagePurchasePrice'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      print('✅ [Service] Parsed ${parsedCoins.length} coins successfully');
      return parsedCoins;
    } catch (e) {
      print('❌ [Service] Error getting stored wallet coins: $e');
      return [];
    }
  }

  // Retrieve all wallet coins with updated market data
  Future<List<WalletCoinModel>> getAllWalletCoins() async {
    try {
      print('🔍 [Service] Getting all wallet coins with market data...');

      // Get stored coins
      final storedCoins = await _getStoredWalletCoins();

      if (storedCoins.isEmpty) {
        print('📭 [Service] No coins in wallet');
        return [];
      }

      print('📊 [Service] Fetching market data for ${storedCoins.length} coins...');

      // Extract symbols for API call
      final List<String> symbols = storedCoins
          .map((coin) => coin.coinDetails.symbol)
          .toList();

      print('🔎 [Service] Symbols: ${symbols.join(", ")}');

      // Fetch current market data for all coins
      final marketResponse = await _coinMarketCapService.getQuotes(symbols: symbols);

      if (!marketResponse.isSuccess) {
        print('⚠️ [Service] Market API call failed: ${marketResponse.errorMessage}');
        print('⚠️ [Service] Returning coins with stale data');
        return storedCoins;
      }

      if (marketResponse.jsonResponse?['data'] == null) {
        print('⚠️ [Service] No market data in response');
        return storedCoins;
      }

      // Process market data
      final quotesData = marketResponse.jsonResponse!['data'] as Map<String, dynamic>;
      print('📈 [Service] Received market data for ${quotesData.keys.length} coins');

      // Debug: Check the format of the first coin's data
      if (quotesData.isNotEmpty) {
        final firstKey = quotesData.keys.first;
        final firstValue = quotesData[firstKey];
        print('🔍 [Service] Data format check - $firstKey is ${firstValue.runtimeType}');
      }

      // Get BTC price for calculations
      double btcPrice = 65000.0; // Default fallback
      if (quotesData.containsKey('BTC')) {
        final btcData = quotesData['BTC'];
        if (btcData != null) {
          try {
            double extractedPrice;
            if (btcData is List && btcData.isNotEmpty) {
              // If it's a list, get first element
              extractedPrice = (btcData[0]['quote']['USD']['price'] as num).toDouble();
            } else if (btcData is Map) {
              // If it's a map, use it directly
              extractedPrice = (btcData['quote']['USD']['price'] as num).toDouble();
            } else {
              extractedPrice = btcPrice;
            }
            btcPrice = extractedPrice;
            print('💰 [Service] BTC price: \$${btcPrice.toStringAsFixed(2)}');
          } catch (e) {
            print('⚠️ [Service] Error parsing BTC price: $e');
          }
        }
      }

      // Update coins with fresh market data
      final updatedCoins = storedCoins.map((walletCoin) {
        final coinSymbol = walletCoin.coinDetails.symbol;
        final coinMarketData = quotesData[coinSymbol];

        if (coinMarketData == null) {
          print('⚠️ [Service] No market data for $coinSymbol, using stored data');
          return walletCoin;
        }

        // Handle both Map and List formats from API
        dynamic marketDataItem;
        if (coinMarketData is List) {
          // If it's a list, get the first element
          if (coinMarketData.isEmpty) {
            print('⚠️ [Service] Empty market data for $coinSymbol');
            return walletCoin;
          }
          marketDataItem = coinMarketData[0];
        } else if (coinMarketData is Map) {
          // If it's a map, use it directly
          marketDataItem = coinMarketData;
        } else {
          print('⚠️ [Service] Unknown market data format for $coinSymbol');
          return walletCoin;
        }

        // Create CoinItem with latest market data
        final updatedCoinItem = CoinItem.fromCoinMarketCap(
          marketDataItem,
          btcPrice: btcPrice,
        );

        print('✅ [Service] Updated $coinSymbol: \$${updatedCoinItem.price.toStringAsFixed(2)} (${updatedCoinItem.percentChange24h >= 0 ? '+' : ''}${updatedCoinItem.percentChange24h.toStringAsFixed(2)}%)');

        // Return wallet coin with updated market data but original purchase info
        return WalletCoinModel(
          coinDetails: updatedCoinItem,
          quantity: walletCoin.quantity,
          averagePurchasePrice: walletCoin.averagePurchasePrice,
        );
      }).toList();

      print('🎉 [Service] Successfully prepared ${updatedCoins.length} coins with fresh data');
      return updatedCoins;
    } catch (e) {
      print('❌ [Service] Error retrieving wallet coins: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Remove a coin from wallet
  Future<bool> removeCoinFromWallet(String symbol) async {
    try {
      print('🗑️ [Service] Removing $symbol from wallet...');

      List<WalletCoinModel> existingCoins = await _getStoredWalletCoins();
      print('📦 [Service] Found ${existingCoins.length} coins before removal');

      final initialCount = existingCoins.length;
      existingCoins.removeWhere((coin) => coin.coinDetails.symbol == symbol);
      final finalCount = existingCoins.length;

      if (initialCount == finalCount) {
        print('⚠️ [Service] Coin $symbol not found in wallet');
        return false;
      }

      print('✂️ [Service] Removed coin. Before: $initialCount, After: $finalCount');

      await _storage.save(
        'wallet_coins',
        existingCoins.map((coin) => coin.toJson()).toList(),
      );

      print('✅ [Service] Successfully removed $symbol from wallet');
      return true;
    } catch (e) {
      print('❌ [Service] Error removing coin from wallet: $e');
      return false;
    }
  }
}