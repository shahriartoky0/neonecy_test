import 'package:get/get.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/coin_market_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../model/crypto_data_model.dart';

class CryptoMarketController extends GetxController {
  RxInt selectedTab = 1.obs;
  RxList<CryptoData> cryptoList = <CryptoData>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  final List<String> tabs = <String>['Favourite', 'Hot', 'Alpha', 'New', 'Gainers'];
  final List<String> categories = <String>['Crypto', 'Spot', 'Futures'];
  RxInt selectedCategory = 0.obs;

  final CoinMarketCapService _cmcService = CoinMarketCapService();
  final Map<String, List<CryptoData>> _cachedData = <String, List<CryptoData>>{};

  // Track last successful load time per cache key
  final Map<String, DateTime> _lastLoadTimes = <String, DateTime>{};
  static const Duration cacheValidDuration = Duration(minutes: 5);

  // ✅ CHANGED: Define max items to show
  static const int maxItemsToShow = 6; // Changed from 10 to 5

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
    // Reload data when category changes
    loadTabData();
  }

  Future<void> loadTabData() async {
    // Create cache key based on tab and category
    final String cacheKey = '${selectedTab.value}_${selectedCategory.value}';

    // Check if cached data is still valid
    if (_cachedData.containsKey(cacheKey) &&
        _lastLoadTimes.containsKey(cacheKey) &&
        DateTime.now().difference(_lastLoadTimes[cacheKey]!) < cacheValidDuration) {
      cryptoList.value = _cachedData[cacheKey]!;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

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

      if (data.isNotEmpty) {
        _cachedData[cacheKey] = data;
        cryptoList.value = data;
        _lastLoadTimes[cacheKey] = DateTime.now();
        errorMessage.value = '';
      } else {
        errorMessage.value = 'No data available';
        cryptoList.value = [];
      }
    } catch (e) {
      LoggerUtils.debug('Error loading tab data: $e');
      errorMessage.value = 'Failed to load data. Please check your internet connection.';
      cryptoList.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Hot: Get trending cryptocurrencies or high volume coins
  Future<List<CryptoData>> _loadHotData() async {
    try {
      // ✅ CHANGED: limit from 10 to 5
      final NetworkResponse trendingResponse = await _cmcService.getTrending(
        limit: maxItemsToShow,
        timePeriod: '24h',
      );

      if (trendingResponse.isSuccess && trendingResponse.jsonResponse != null) {
        final data = trendingResponse.jsonResponse?['data'] as List? ?? [];

        if (data.isNotEmpty) {
          return data.map((coin) {
            final quote = coin['quote']?['USD'] ?? {};
            return CryptoData(
              symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
              price: (quote['price'] ?? 0.0).toDouble(),
              formattedPrice: _formatPrice(quote['price'] ?? 0.0),
              changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
              name: coin['name'] ?? '',
              volume: quote['volume_24h']?.toDouble(),
              marketCap: quote['market_cap']?.toDouble(),
              subText: _formatVolume(quote['volume_24h']),
            );
          }).toList();
        }
      }

      // ✅ CHANGED: limit from 10 to 5
      final NetworkResponse response = await _cmcService.getLatestListings(
        limit: maxItemsToShow,
        sort: 'volume_24h',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data'] as List? ?? [];

        return data.map((coin) {
          final quote = coin['quote']?['USD'] ?? {};
          return CryptoData(
            symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
            price: (quote['price'] ?? 0.0).toDouble(),
            formattedPrice: _formatPrice(quote['price'] ?? 0.0),
            changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
            name: coin['name'] ?? '',
            volume: quote['volume_24h']?.toDouble(),
            marketCap: quote['market_cap']?.toDouble(),
            subText: _formatVolume(quote['volume_24h']),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      LoggerUtils.debug('Exception in hot data: $e');
      return [];
    }
  }

  // Gainers: Get top gainers
  Future<List<CryptoData>> _loadGainersData() async {
    try {
      // ✅ CHANGED: limit from 10 to 5
      final NetworkResponse gainersResponse = await _cmcService.getTopGainers(
        limit: maxItemsToShow,
        timePeriod: '24h',
      );

      if (gainersResponse.isSuccess && gainersResponse.jsonResponse != null) {
        final data = gainersResponse.jsonResponse?['data'] as List? ?? [];

        if (data.isNotEmpty) {
          return data.map((coin) {
            final quote = coin['quote']?['USD'] ?? {};
            return CryptoData(
              symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
              price: (quote['price'] ?? 0.0).toDouble(),
              formattedPrice: _formatPrice(quote['price'] ?? 0.0),
              changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
              name: coin['name'] ?? '',
              volume: quote['volume_24h']?.toDouble(),
              marketCap: quote['market_cap']?.toDouble(),
              subText: _formatMarketCap(quote['market_cap']),
            );
          }).toList();
        }
      }

      // Fallback: Get top coins and sort by percent change
      final NetworkResponse response = await _cmcService.getLatestListings(
        limit: 100,
        sort: 'percent_change_24h',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data'] as List? ?? [];

        // ✅ CHANGED: .take(10) to .take(5)
        final gainers = data.where((coin) {
          final change = coin['quote']?['USD']?['percent_change_24h'] ?? 0;
          return change > 0;
        }).take(maxItemsToShow);

        return gainers.map((coin) {
          final quote = coin['quote']?['USD'] ?? {};
          return CryptoData(
            symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
            price: (quote['price'] ?? 0.0).toDouble(),
            formattedPrice: _formatPrice(quote['price'] ?? 0.0),
            changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
            name: coin['name'] ?? '',
            volume: quote['volume_24h']?.toDouble(),
            marketCap: quote['market_cap']?.toDouble(),
            subText: _formatMarketCap(quote['market_cap']),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      LoggerUtils.debug('Exception in gainers: $e');
      return [];
    }
  }

  // Favourite: Top 5 by market cap
  Future<List<CryptoData>> _loadFavouriteData() async {
    try {
      // ✅ CHANGED: limit from 10 to 5
      final NetworkResponse response = await _cmcService.getLatestListings(
        limit: maxItemsToShow,
        sort: 'market_cap',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data'] as List? ?? [];

        return data.map((coin) {
          final quote = coin['quote']?['USD'] ?? {};
          return CryptoData(
            symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
            price: (quote['price'] ?? 0.0).toDouble(),
            formattedPrice: _formatPrice(quote['price'] ?? 0.0),
            changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
            name: coin['name'] ?? '',
            volume: quote['volume_24h']?.toDouble(),
            marketCap: quote['market_cap']?.toDouble(),
            subText: _formatMarketCap(quote['market_cap']),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      LoggerUtils.debug('Exception in favourites: $e');
      return [];
    }
  }

  // New: Recently added coins
  Future<List<CryptoData>> _loadNewData() async {
    try {
      // ✅ CHANGED: limit from 10 to 5
      final NetworkResponse response = await _cmcService.getNewListings(
        limit: maxItemsToShow,
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data'] as List? ?? [];

        if (data.isNotEmpty) {
          return data.map((coin) {
            final quote = coin['quote']?['USD'] ?? {};
            return CryptoData(
              symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
              price: (quote['price'] ?? 0.0).toDouble(),
              formattedPrice: _formatPrice(quote['price'] ?? 0.0),
              changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
              name: coin['name'] ?? '',
              volume: quote['volume_24h']?.toDouble(),
              marketCap: quote['market_cap']?.toDouble(),
              subText: 'Rank #${coin['cmc_rank'] ?? 'N/A'}',
            );
          }).toList();
        }
      }

      // ✅ CHANGED: limit from 10 to 5
      final fallbackResponse = await _cmcService.getLatestListings(
        start: 51,
        limit: maxItemsToShow,
        sort: 'date_added',
        sortDir: 'desc',
      );

      if (fallbackResponse.isSuccess && fallbackResponse.jsonResponse != null) {
        final data = fallbackResponse.jsonResponse?['data'] as List? ?? [];

        return data.map((coin) {
          final quote = coin['quote']?['USD'] ?? {};
          return CryptoData(
            symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
            price: (quote['price'] ?? 0.0).toDouble(),
            formattedPrice: _formatPrice(quote['price'] ?? 0.0),
            changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
            name: coin['name'] ?? '',
            volume: quote['volume_24h']?.toDouble(),
            marketCap: quote['market_cap']?.toDouble(),
            subText: 'Rank #${coin['cmc_rank'] ?? 'N/A'}',
          );
        }).toList();
      }

      return [];
    } catch (e) {
      LoggerUtils.debug('Exception in new coins: $e');
      return [];
    }
  }

  // Alpha: Mid-cap coins with high volatility
  Future<List<CryptoData>> _loadAlphaData() async {
    try {
      // Get coins from rank 21-50 (mid-cap range)
      final NetworkResponse response = await _cmcService.getLatestListings(
        start: 21,
        limit: 50,
        sort: 'market_cap',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse?['data'] as List? ?? [];

        // ✅ CHANGED: .take(10) to .take(5)
        final alphaCoins = data.where((coin) {
          final quote = coin['quote']?['USD'] ?? {};
          final volume = quote['volume_24h'] ?? 0;
          final change = (quote['percent_change_24h'] ?? 0).abs();
          return volume > 10000000 && change > 5;
        }).take(maxItemsToShow);

        if (alphaCoins.isNotEmpty) {
          return alphaCoins.map((coin) {
            final quote = coin['quote']?['USD'] ?? {};
            return CryptoData(
              symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
              price: (quote['price'] ?? 0.0).toDouble(),
              formattedPrice: _formatPrice(quote['price'] ?? 0.0),
              changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
              name: coin['name'] ?? '',
              volume: quote['volume_24h']?.toDouble(),
              marketCap: quote['market_cap']?.toDouble(),
              subText: _formatMarketCap(quote['market_cap']),
            );
          }).toList();
        }

        // ✅ CHANGED: .take(10) to .take(5)
        return data.take(maxItemsToShow).map((coin) {
          final quote = coin['quote']?['USD'] ?? {};
          return CryptoData(
            symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
            price: (quote['price'] ?? 0.0).toDouble(),
            formattedPrice: _formatPrice(quote['price'] ?? 0.0),
            changePercent: (quote['percent_change_24h'] ?? 0.0).toDouble(),
            name: coin['name'] ?? '',
            volume: quote['volume_24h']?.toDouble(),
            marketCap: quote['market_cap']?.toDouble(),
            subText: _formatMarketCap(quote['market_cap']),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      LoggerUtils.debug('Exception in alpha coins: $e');
      return [];
    }
  }

  // Helper methods
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final double p = price is double ? price : (price is int ? price.toDouble() : 0.0);

    if (p >= 1000) {
      return p.toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},');
    } else if (p >= 1) {
      return p.toStringAsFixed(2);
    } else if (p >= 0.01) {
      return p.toStringAsFixed(4);
    } else if (p >= 0.0001) {
      return p.toStringAsFixed(6);
    } else if (p >= 0.00000001) {
      return p.toStringAsFixed(8);
    } else {
      return p.toStringAsExponential(2);
    }
  }

  String _formatVolume(dynamic volume) {
    if (volume == null) return 'Vol: N/A';
    final double v = volume is double ? volume : (volume is int ? volume.toDouble() : 0.0);

    if (v >= 1e12) {
      return 'Vol: \$${(v / 1e12).toStringAsFixed(1)}T';
    } else if (v >= 1e9) {
      return 'Vol: \$${(v / 1e9).toStringAsFixed(1)}B';
    } else if (v >= 1e6) {
      return 'Vol: \$${(v / 1e6).toStringAsFixed(1)}M';
    } else if (v >= 1e3) {
      return 'Vol: \$${(v / 1e3).toStringAsFixed(0)}K';
    } else {
      return 'Vol: \$${v.toStringAsFixed(0)}';
    }
  }

  String _formatMarketCap(dynamic marketCap) {
    if (marketCap == null) return 'MCap: N/A';
    final double m = marketCap is double ? marketCap : (marketCap is int ? marketCap.toDouble() : 0.0);

    if (m >= 1e12) {
      return 'MCap: \$${(m / 1e12).toStringAsFixed(2)}T';
    } else if (m >= 1e9) {
      return 'MCap: \$${(m / 1e9).toStringAsFixed(1)}B';
    } else if (m >= 1e6) {
      return 'MCap: \$${(m / 1e6).toStringAsFixed(1)}M';
    } else if (m >= 1e3) {
      return 'MCap: \$${(m / 1e3).toStringAsFixed(0)}K';
    } else {
      return 'MCap: \$${m.toStringAsFixed(0)}';
    }
  }

  // Refresh current tab
  Future<void> refreshCurrentTab() async {
    final String cacheKey = '${selectedTab.value}_${selectedCategory.value}';
    _cachedData.remove(cacheKey);
    _lastLoadTimes.remove(cacheKey);
    await loadTabData();
  }

  // Clear all cache
  void clearCache() {
    _cachedData.clear();
    _lastLoadTimes.clear();
  }

  // Balance property
  final RxString balance = ''.obs;
}