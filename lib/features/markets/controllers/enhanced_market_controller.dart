import 'package:get/get.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/coin_market_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../model/enhanced_crypto_data_model.dart';

class EnhancedCryptoMarketController extends GetxController {
  final RxList<EnhancedCryptoData> _allCryptoList = <EnhancedCryptoData>[].obs;
  final RxList<EnhancedCryptoData> cryptoList = <EnhancedCryptoData>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'market_cap'.obs;
  final RxBool isAscending = false.obs;
  final RxList<String> favoriteSymbols = <String>[].obs;

  final CoinMarketCapService _cmcService = CoinMarketCapService();

  @override
  void onInit() {
    super.onInit();
    fetchMarketData();
    searchQuery.listen((_) => _filterCryptoList());
    sortBy.listen((_) => _filterCryptoList());
    isAscending.listen((_) => _filterCryptoList());
  }

  Future<void> fetchMarketData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final NetworkResponse response = await _cmcService.getLatestListings(
        limit: 20,
        sort: 'market_cap',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final List<dynamic> data = response.jsonResponse?['data'] as List<dynamic>? ?? <dynamic>[];
        final List<EnhancedCryptoData> coins = <EnhancedCryptoData>[];

        for (int i = 0; i < data.length; i++) {
          final Map<String, dynamic> coin = data[i] as Map<String, dynamic>;
          final Map<String, dynamic> quote =
              (coin['quote'] as Map<String, dynamic>?)?['USD'] as Map<String, dynamic>? ?? <String, dynamic>{};
          coins.add(
            EnhancedCryptoData(
              coinId: (coin['id'] as num?)?.toInt() ?? 0,
              symbol: (coin['symbol'] ?? '').toString().toUpperCase(),
              name: (coin['name'] ?? '').toString(),
              price: (quote['price'] as num?)?.toDouble() ?? 0.0,
              changePercent: (quote['percent_change_24h'] as num?)?.toDouble() ?? 0.0,
              volume: (quote['volume_24h'] as num?)?.toDouble() ?? 0.0,
              leverage: i < 10 ? '10x' : '5x',
            ),
          );
        }

        _allCryptoList.assignAll(coins);
        _filterCryptoList();
      } else {
        errorMessage.value = 'Failed to load market data';
        LoggerUtils.debug('Market API error: ${response.errorMessage}');
      }
    } catch (e) {
      LoggerUtils.debug('Error fetching market data: $e');
      errorMessage.value = 'Failed to load data';
    } finally {
      isLoading.value = false;
    }
  }

  void changeSortField(String field) {
    if (sortBy.value == field) {
      isAscending.value = !isAscending.value;
    } else {
      sortBy.value = field;
      isAscending.value = true;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void _filterCryptoList() {
    final List<EnhancedCryptoData> filtered = _allCryptoList.where((EnhancedCryptoData crypto) {
      return crypto.symbol.toLowerCase().contains(searchQuery.value) ||
          crypto.name.toLowerCase().contains(searchQuery.value);
    }).toList();
    _sortCryptoList(filtered);
    cryptoList.assignAll(filtered);
  }

  void _sortCryptoList(List<EnhancedCryptoData> list) {
    list.sort((EnhancedCryptoData a, EnhancedCryptoData b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'symbol':
          comparison = a.symbol.compareTo(b.symbol);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'change':
          comparison = a.changePercent.compareTo(b.changePercent);
          break;
        case 'volume':
          comparison = a.volume.compareTo(b.volume);
          break;
        default:
          comparison = 0;
      }
      return isAscending.value ? comparison : -comparison;
    });
  }

  void toggleFavorite(String symbol) {
    if (favoriteSymbols.contains(symbol)) {
      favoriteSymbols.remove(symbol);
    } else {
      favoriteSymbols.add(symbol);
    }
    final int index = _allCryptoList.indexWhere((EnhancedCryptoData c) => c.symbol == symbol);
    if (index != -1) {
      _allCryptoList[index] = _allCryptoList[index].copyWith(
        isFavorite: favoriteSymbols.contains(symbol),
      );
    }
    _filterCryptoList();
  }

  bool isFavorite(String symbol) => favoriteSymbols.contains(symbol);

  Future<void> refreshData() async {
    await fetchMarketData();
  }
}