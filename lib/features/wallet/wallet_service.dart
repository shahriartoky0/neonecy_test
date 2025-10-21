// lib/features/wallet/services/wallet_service.dart
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
      // Retrieve existing wallet coins
      List<WalletCoinModel> existingCoins = await getAllWalletCoins();

      // Check if coin already exists
      final existingCoinIndex = existingCoins.indexWhere(
              (coin) => coin.coinDetails.symbol == walletCoin.coinDetails.symbol
      );

      if (existingCoinIndex != -1) {
        // Update existing coin
        existingCoins[existingCoinIndex] = walletCoin;
      } else {
        // Add new coin
        existingCoins.add(walletCoin);
      }

      // Save updated list
      await _storage.save(
          'wallet_coins',
          existingCoins.map((coin) => coin.toJson()).toList()
      );
      return true;
    } catch (e) {
      print('Error adding coin to wallet: $e');
      return false;
    }
  }

  // Retrieve all wallet coins with updated market data
  Future<List<WalletCoinModel>> getAllWalletCoins() async {
    try {
      // Retrieve stored coin data
      final storedCoins = _storage.read('wallet_coins');

      if (storedCoins == null) return [];

      // Fetch current market data for all coins
      final List<String> symbols =
      (storedCoins as List).map((coin) => coin['symbol'] as String).toList();

      final marketResponse = await _coinMarketCapService.getQuotes(symbols: symbols);

      if (!marketResponse.isSuccess) {
        // Return stored coins without updated market data
        return (storedCoins as List).map((coinJson) {
          return WalletCoinModel.fromJson(
              coinJson,
              CoinItem(
                  id: coinJson['coinId'].toString(),
                  coinId: coinJson['coinId'],
                  name: '',
                  symbol: coinJson['symbol'],
                  marketCapRank: 0,
                  thumb: '',
                  small: '',
                  large: '',
                  slug: '',
                  price: 0.0,
                  priceBtc: 0.0,
                  marketCap: '',
                  totalVolume: '',
                  sparkline: ''
              )
          );
        }).toList();
      }

      // Process market data
      final quotesData = marketResponse.jsonResponse?['data'] ?? {};

      // Convert stored coins to WalletCoinModel with updated market data
      return (storedCoins as List).map((coinJson) {
        final coinSymbol = coinJson['symbol'];
        final coinMarketData = quotesData[coinSymbol];

        // Create CoinItem with latest market data
        final coinItem = CoinItem.fromCoinMarketCap(coinMarketData);

        return WalletCoinModel.fromJson(coinJson, coinItem);
      }).toList();
    } catch (e) {
      print('Error retrieving wallet coins: $e');
      return [];
    }
  }

  // Remove a coin from wallet
  Future<bool> removeCoinFromWallet(String symbol) async {
    try {
      List<WalletCoinModel> existingCoins = await getAllWalletCoins();

      existingCoins.removeWhere((coin) => coin.coinDetails.symbol == symbol);

      await _storage.save(
          'wallet_coins',
          existingCoins.map((coin) => coin.toJson()).toList()
      );
      return true;
    } catch (e) {
      print('Error removing coin from wallet: $e');
      return false;
    }
  }
}