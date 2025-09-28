import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:neonecy_test/core/network/network_response.dart';

import '../../../core/utils/coin_gecko.dart';
import '../../../core/utils/logger_utils.dart';
import '../model/crypto_data_model.dart';

class CryptoMarketController extends GetxController {
  RxInt selectedTab = 1.obs;
  RxList<CryptoData> cryptoList = <CryptoData>[].obs;
  RxBool isLoading = false.obs;

  final List<String> tabs = <String>['Favourite', 'Hot', 'Alpha', 'New', 'Gainers'];
  final List<String> categories = <String>['Crypto', 'Spot', 'Futures'];
  RxInt selectedCategory = 0.obs;

  final CoinGeckoService _geckoService = CoinGeckoService();
  final Map<int, List<CryptoData>> _cachedData = <int, List<CryptoData>>{};

  @override
  void onInit() {
    super.onInit();
    loadTabData();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    loadTabData();
  }

  void selectCategory(int index) {
    selectedCategory.value = index;
  }

  Future<void> loadTabData() async {
    // Use cached data if available
    if (_cachedData.containsKey(selectedTab.value)) {
      cryptoList.value = _cachedData[selectedTab.value]!;
      return;
    }

    isLoading.value = true;

    try {
      List<CryptoData> data = <CryptoData>[];

      switch (selectedTab.value) {
        case 0: // Favourite
          data = await _loadFavouriteData();
          break;
        case 1: // Hot
          data = await _loadHotData();
          break;
        case 2: // Alpha
          data = await _loadAlphaData();
          break;
        case 3: // New
          data = await _loadNewData();
          break;
        case 4: // Gainers
          data = await _loadGainersData();
          break;
      }

      _cachedData[selectedTab.value] = data;
      cryptoList.value = data;
    } catch (e) {
      LoggerUtils.debug('Error loading tab data: $e');
      // Load demo data as fallback
      _loadDemoDataForTab(selectedTab.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Hot: Trending coins with volume
  Future<List<CryptoData>> _loadHotData() async {
    final NetworkResponse response = await _geckoService.getTrendingCoins();

    if (!response.isSuccess) {
      LoggerUtils.debug('Hot data failed, using fallback');
      return _getDemoHotData();
    }

    final List trendingCoins = response.jsonResponse?['coins'] as List? ?? <dynamic>[];
    List<CryptoData> hotCryptos = <CryptoData>[];

    for (var coin in trendingCoins.take(10)) {
      final coinData = coin['item'];
      final NetworkResponse priceResponse = await _geckoService.getCoinPrice(
        coinId: coinData['id'],
        includeMarketCap: true,
        include24hrVol: true,
        include24hrChange: true,
      );

      if (priceResponse.isSuccess) {
        final priceData = priceResponse.jsonResponse?[coinData['id']];
        hotCryptos.add(
          CryptoData(
            symbol: coinData['symbol'].toString().toUpperCase(),
            price: (priceData?['usd'] ?? 0.0).toDouble(),
            formattedPrice: _formatPrice(priceData?['usd'] ?? 0.0),
            changePercent: (priceData?['usd_24h_change'] ?? 0.0).toDouble(),
            name: coinData['name'] ?? '',
            volume: priceData?['usd_24h_vol']?.toDouble(),
            marketCap: priceData?['usd_market_cap']?.toDouble(),
            subText: _formatVolume(priceData?['usd_24h_vol']),
          ),
        );
      }
      await Future.delayed(Duration(milliseconds: 50));
    }

    LoggerUtils.debug('Loaded ${hotCryptos.length} hot cryptocurrencies');
    return hotCryptos.isNotEmpty ? hotCryptos : _getDemoHotData();
  }

  // Gainers: Use simple top coins and filter
  Future<List<CryptoData>> _loadGainersData() async {
    try {
      // Use the basic getTopCoins method that should exist
      final NetworkResponse response = await _geckoService.getTopCoins(
        vsCurrency: 'usd',
        perPage: 50,
      );

      if (!response.isSuccess) {
        LoggerUtils.debug('Gainers API failed, using demo data');
        return _getDemoGainersData();
      }

      final List coins = response.jsonResponse as List? ?? <dynamic>[];
      LoggerUtils.debug('Gainers raw data count: ${coins.length}');

      if (coins.isEmpty) {
        return _getDemoGainersData();
      }

      // Filter and sort by positive 24h change
      final List gainers =
          coins.where((coin) => (coin['price_change_percentage_24h'] ?? 0) > 0).toList()..sort(
            (a, b) => (b['price_change_percentage_24h'] ?? 0).compareTo(
              a['price_change_percentage_24h'] ?? 0,
            ),
          );

      List<CryptoData> gainersData = gainers.take(10).map((coin) {
        return CryptoData(
          symbol: coin['symbol'].toString().toUpperCase(),
          price: (coin['current_price'] ?? 0.0).toDouble(),
          formattedPrice: _formatPrice(coin['current_price'] ?? 0.0),
          changePercent: (coin['price_change_percentage_24h'] ?? 0.0).toDouble(),
          name: coin['name'] ?? '',
          marketCap: coin['market_cap']?.toDouble(),
          volume: coin['total_volume']?.toDouble(),
          subText: _formatMarketCap(coin['market_cap']),
        );
      }).toList();

      LoggerUtils.debug('Loaded ${gainersData.length} gainer cryptocurrencies');
      return gainersData.isNotEmpty ? gainersData : _getDemoGainersData();
    } catch (e) {
      LoggerUtils.debug('Exception in gainers: $e');
      return _getDemoGainersData();
    }
  }

  // Favourite: Use basic API call
  Future<List<CryptoData>> _loadFavouriteData() async {
    try {
      // Simple approach - get top 10 coins by market cap
      final NetworkResponse response = await _geckoService.getTopCoins(
        vsCurrency: 'usd',
        perPage: 10,
      );

      if (!response.isSuccess) {
        LoggerUtils.debug('Favourites API failed, using demo data');
        return _getDemoFavouriteData();
      }

      final List coins = response.jsonResponse as List? ?? <dynamic>[];

      if (coins.isEmpty) {
        return _getDemoFavouriteData();
      }

      List<CryptoData> favorites = coins.map((coin) {
        return CryptoData(
          symbol: coin['symbol'].toString().toUpperCase(),
          price: (coin['current_price'] ?? 0.0).toDouble(),
          formattedPrice: _formatPrice(coin['current_price'] ?? 0.0),
          changePercent: (coin['price_change_percentage_24h'] ?? 0.0).toDouble(),
          name: coin['name'] ?? '',
          marketCap: coin['market_cap']?.toDouble(),
          volume: coin['total_volume']?.toDouble(),
          subText: _formatMarketCap(coin['market_cap']),
        );
      }).toList();

      LoggerUtils.debug('Loaded ${favorites.length} favourite cryptocurrencies');
      return favorites;
    } catch (e) {
      LoggerUtils.debug('Exception in favourites: $e');
      return _getDemoFavouriteData();
    }
  }

  // New: Get coins from page 2-3 (newer/smaller coins)
  Future<List<CryptoData>> _loadNewData() async {
    try {
      final NetworkResponse response = await _geckoService.getTopCoins(
        vsCurrency: 'usd',
        perPage: 50,
        page: 2,
      );

      if (!response.isSuccess) {
        LoggerUtils.debug('New coins API failed, using demo data');
        return _getDemoNewData();
      }

      final List coins = response.jsonResponse as List? ?? <dynamic>[];

      if (coins.isEmpty) {
        return _getDemoNewData();
      }

      List<CryptoData> newData = coins.take(10).map((coin) {
        return CryptoData(
          symbol: coin['symbol'].toString().toUpperCase(),
          price: (coin['current_price'] ?? 0.0).toDouble(),
          formattedPrice: _formatPrice(coin['current_price'] ?? 0.0),
          changePercent: (coin['price_change_percentage_24h'] ?? 0.0).toDouble(),
          name: coin['name'] ?? '',
          marketCap: coin['market_cap']?.toDouble(),
          volume: coin['total_volume']?.toDouble(),
          subText: 'Rank #${coin['market_cap_rank'] ?? 'N/A'}',
        );
      }).toList();

      LoggerUtils.debug('Loaded ${newData.length} new cryptocurrencies');
      return newData;
    } catch (e) {
      LoggerUtils.debug('Exception in new coins: $e');
      return _getDemoNewData();
    }
  }

  // Alpha: Get smaller cap coins from page 3-4
  Future<List<CryptoData>> _loadAlphaData() async {
    try {
      final NetworkResponse response = await _geckoService.getTopCoins(
        vsCurrency: 'usd',
        perPage: 50,
        page: 3,
      );

      if (!response.isSuccess) {
        LoggerUtils.debug('Alpha coins API failed, using demo data');
        return _getDemoAlphaData();
      }

      final List coins = response.jsonResponse as List? ?? <dynamic>[];

      if (coins.isEmpty) {
        return _getDemoAlphaData();
      }

      List<CryptoData> alphaData = coins.take(10).map((coin) {
        return CryptoData(
          symbol: coin['symbol'].toString().toUpperCase(),
          price: (coin['current_price'] ?? 0.0).toDouble(),
          formattedPrice: _formatPrice(coin['current_price'] ?? 0.0),
          changePercent: (coin['price_change_percentage_24h'] ?? 0.0).toDouble(),
          name: coin['name'] ?? '',
          marketCap: coin['market_cap']?.toDouble(),
          volume: coin['total_volume']?.toDouble(),
          subText: _formatMarketCap(coin['market_cap']),
        );
      }).toList();

      LoggerUtils.debug('Loaded ${alphaData.length} alpha cryptocurrencies');
      return alphaData;
    } catch (e) {
      LoggerUtils.debug('Exception in alpha coins: $e');
      return _getDemoAlphaData();
    }
  }

  // Demo data fallbacks
  List<CryptoData> _getDemoHotData() {
    return [
      CryptoData(
        symbol: 'BTC',
        price: 67890,
        formattedPrice: '67,890',
        changePercent: 8.45,
        name: 'Bitcoin',
        subText: 'Vol: \$2.5B',
      ),
      CryptoData(
        symbol: 'ETH',
        price: 3456,
        formattedPrice: '3,456',
        changePercent: 6.78,
        name: 'Ethereum',
        subText: 'Vol: \$1.2B',
      ),
      CryptoData(
        symbol: 'SOL',
        price: 145,
        formattedPrice: '145',
        changePercent: 12.34,
        name: 'Solana',
        subText: 'Vol: \$890M',
      ),
    ];
  }

  List<CryptoData> _getDemoGainersData() {
    return [
      CryptoData(
        symbol: 'PEPE',
        price: 0.000012,
        formattedPrice: '0.000012',
        changePercent: 45.67,
        name: 'Pepe',
        subText: 'MCap: \$5.2B',
      ),
      CryptoData(
        symbol: 'SHIB',
        price: 0.000008,
        formattedPrice: '0.000008',
        changePercent: 23.45,
        name: 'Shiba Inu',
        subText: 'MCap: \$4.8B',
      ),
      CryptoData(
        symbol: 'DOGE',
        price: 0.062,
        formattedPrice: '0.062',
        changePercent: 12.34,
        name: 'Dogecoin',
        subText: 'MCap: \$8.9B',
      ),
    ];
  }

  List<CryptoData> _getDemoFavouriteData() {
    return [
      CryptoData(
        symbol: 'BTC',
        price: 67890,
        formattedPrice: '67,890',
        changePercent: 2.45,
        name: 'Bitcoin',
        subText: 'MCap: \$1.3T',
      ),
      CryptoData(
        symbol: 'ETH',
        price: 3456,
        formattedPrice: '3,456',
        changePercent: -1.23,
        name: 'Ethereum',
        subText: 'MCap: \$415B',
      ),
      CryptoData(
        symbol: 'BNB',
        price: 345,
        formattedPrice: '345',
        changePercent: 4.32,
        name: 'BNB',
        subText: 'MCap: \$52B',
      ),
    ];
  }

  List<CryptoData> _getDemoNewData() {
    return [
      CryptoData(
        symbol: 'ARB',
        price: 0.85,
        formattedPrice: '0.85',
        changePercent: 8.45,
        name: 'Arbitrum',
        subText: 'Rank #45',
      ),
      CryptoData(
        symbol: 'OP',
        price: 1.23,
        formattedPrice: '1.23',
        changePercent: -2.15,
        name: 'Optimism',
        subText: 'Rank #67',
      ),
      CryptoData(
        symbol: 'BLUR',
        price: 0.34,
        formattedPrice: '0.34',
        changePercent: 15.67,
        name: 'Blur',
        subText: 'Rank #89',
      ),
    ];
  }

  List<CryptoData> _getDemoAlphaData() {
    return [
      CryptoData(
        symbol: 'GMT',
        price: 0.15,
        formattedPrice: '0.15',
        changePercent: -5.23,
        name: 'STEPN',
        subText: 'MCap: \$89M',
      ),
      CryptoData(
        symbol: 'MAGIC',
        price: 0.67,
        formattedPrice: '0.67',
        changePercent: 12.45,
        name: 'Magic',
        subText: 'MCap: \$156M',
      ),
      CryptoData(
        symbol: 'IMX',
        price: 1.34,
        formattedPrice: '1.34',
        changePercent: -8.76,
        name: 'Immutable X',
        subText: 'MCap: \$234M',
      ),
    ];
  }

  void _loadDemoDataForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        cryptoList.value = _getDemoFavouriteData();
        break;
      case 1:
        cryptoList.value = _getDemoHotData();
        break;
      case 2:
        cryptoList.value = _getDemoAlphaData();
        break;
      case 3:
        cryptoList.value = _getDemoNewData();
        break;
      case 4:
        cryptoList.value = _getDemoGainersData();
        break;
    }
  }

  // Helper methods (same as before)
  String _formatPrice(double price) {
    if (price >= 1000) {
      return price
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  String _formatVolume(double? volume) {
    if (volume == null || volume == 0) return 'Vol: N/A';
    if (volume >= 1e9) {
      return 'Vol: \$${(volume / 1e9).toStringAsFixed(1)}B';
    } else if (volume >= 1e6) {
      return 'Vol: \$${(volume / 1e6).toStringAsFixed(1)}M';
    } else {
      return 'Vol: \$${(volume / 1e3).toStringAsFixed(0)}K';
    }
  }

  String _formatMarketCap(double? marketCap) {
    if (marketCap == null || marketCap == 0) return 'MCap: N/A';
    if (marketCap >= 1e9) {
      return 'MCap: \$${(marketCap / 1e9).toStringAsFixed(1)}B';
    } else if (marketCap >= 1e6) {
      return 'MCap: \$${(marketCap / 1e6).toStringAsFixed(1)}M';
    } else {
      return 'MCap: \$${(marketCap / 1e3).toStringAsFixed(0)}K';
    }
  }

  // Refresh current tab
  Future<void> refreshCurrentTab() async {
    _cachedData.remove(selectedTab.value);
    await loadTabData();
  }

  // Clear all cache
  void clearCache() {
    _cachedData.clear();
  }

  /// ==================> for the balance ===========>
  final RxString balance = ''.obs;
}
