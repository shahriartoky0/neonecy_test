// lib/features/assets/controllers/assets_controller.dart

import 'package:get/get.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/coin_market_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../model/coin_model.dart';

class AssetsController extends GetxController {
  // Observable variables
  RxList<CoinItem> coinItems = <CoinItem>[].obs;
  RxBool isLoadingCoin = false.obs;
  RxBool lessThanDollarItems = false.obs;

  final CoinMarketCapService _cmcService = CoinMarketCapService();

  // Cache for BTC price (to calculate BTC values)
  double _btcPrice = 65000; // Default fallback
  /// ====> For the lower tabs
  RxString selectedBottomTab = 'Crypto'.obs;

  // To handle loading state
  RxBool isLoadingBottomTab = false.obs;

  void selectBottomTab(String tab) {
    selectedBottomTab.value = tab;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCoinData();
  }

  // Toggle hide assets functionality
  void toggleHideAssets() {
    lessThanDollarItems.value = !lessThanDollarItems.value;
    // If hiding small assets, filter the list
    if (lessThanDollarItems.value) {
      filterAssets();
    } else {
      fetchCoinData(); // Reload all assets
    }
  }

  // Filter assets less than $1
  void filterAssets() {
    coinItems.value = coinItems.where((coin) => coin.price >= 1.1).toList();
  }

  // Refresh functionality
  Future<void> onRefresh() async {
    await fetchCoinData();
  }

  // Updated fetchCoinData using CoinMarketCapService
  Future<void> fetchCoinData() async {
    isLoadingCoin.value = true;

    try {
      // Fetch top cryptocurrencies from CoinMarketCap
      final NetworkResponse response = await _cmcService.getLatestListings(
        limit: 50, // Get top 50 coins
        sort: 'market_cap',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final List<dynamic> coinList = response.jsonResponse?['data'] ?? [];

        // Get BTC price for conversion (first item is usually BTC)
        if (coinList.isNotEmpty) {
          final btcData = coinList.firstWhere(
            (coin) => coin['symbol'] == 'BTC',
            orElse: () => coinList.first,
          );
          _btcPrice = (btcData['quote']?['USD']?['price'] ?? 65000).toDouble();
        }

        // Map the response data into CoinItem objects
        final List<CoinItem> allCoins = coinList.map((dynamic coinJson) {
          return CoinItem.fromCoinMarketCap(coinJson, btcPrice: _btcPrice);
        }).toList();

        // Apply filter if needed
        if (lessThanDollarItems.value) {
          coinItems.value = allCoins.where((coin) => coin.price >= 1.0).toList();
        } else {
          coinItems.value = allCoins;
        }

        LoggerUtils.debug('Successfully fetched ${coinItems.length} coins from CoinMarketCap');
      } else {
        LoggerUtils.error('Error: CoinMarketCap API response was not successful');
        // Fallback to trending if main API fails
        await fetchTrendingCoins();
      }
    } catch (e) {
      LoggerUtils.error('Failed to fetch coin data from CoinMarketCap: $e');
      // Try fallback to trending
      await fetchTrendingCoins();
    } finally {
      isLoadingCoin.value = false;
    }
  }

  // Fallback method to get trending coins
  Future<void> fetchTrendingCoins() async {
    try {
      final NetworkResponse response = await _cmcService.getTrending(limit: 20, timePeriod: '24h');

      if (response.isSuccess && response.jsonResponse != null) {
        final List<dynamic> coinList = response.jsonResponse?['data'] ?? [];

        // Map trending coins
        final List<CoinItem> trendingCoins = coinList.map((dynamic coinJson) {
          return CoinItem.fromCoinMarketCap(coinJson, btcPrice: _btcPrice);
        }).toList();

        if (lessThanDollarItems.value) {
          coinItems.value = trendingCoins.where((coin) => coin.price >= 1.0).toList();
        } else {
          coinItems.value = trendingCoins;
        }

        LoggerUtils.debug('Loaded ${coinItems.length} trending coins as fallback');
      }
    } catch (e) {
      LoggerUtils.error('Failed to fetch trending coins: $e');
      // If all fails, keep the list empty or show cached data
    }
  }

  // Method to update BTC price for conversion
  Future<void> updateBtcPrice() async {
    try {
      final NetworkResponse response = await _cmcService.getQuotes(symbols: ['BTC']);

      if (response.isSuccess && response.jsonResponse != null) {
        final btcData = response.jsonResponse?['data']?['BTC'];
        if (btcData != null) {
          _btcPrice = (btcData['quote']?['USD']?['price'] ?? 65000).toDouble();
          LoggerUtils.debug('Updated BTC price: $_btcPrice');
        }
      }
    } catch (e) {
      LoggerUtils.error('Failed to update BTC price: $e');
    }
  }
}
