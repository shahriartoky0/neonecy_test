// lib/features/assets/controller/coin_selection_controller.dart

import 'package:get/get.dart';
import 'package:neonecy_test/core/network/network_response.dart';

import '../../../core/utils/coin_market_service.dart';
import '../../assets/model/coin_model.dart';

class CoinSelectionController extends GetxController {
  final CoinMarketCapService _coinMarketCapService = CoinMarketCapService();

  final RxList<CoinItem> coins = <CoinItem>[].obs;
  final RxList<CoinItem> filteredCoins = <CoinItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;
  RxInt selectedTab = 0.obs;

  void selectTab(int index) {
    selectedTab.value = index;
  }

  bool isSingleCoinSelected() => selectedTab.value == 0;

  bool isMultipleCoinSelected() => selectedTab.value == 1;

  // BTC price for calculations
  final RxDouble btcPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoins();
  }

  Future<void> fetchCoins() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final NetworkResponse response = await _coinMarketCapService.getLatestListings(
        limit: 100,
        sort: 'market_cap',
        sortDir: 'desc',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final List data = response.jsonResponse!['data'] as List;

        // Find BTC price first
        final btcData = data.firstWhere((coin) => coin['symbol'] == 'BTC', orElse: () => null);

        if (btcData != null) {
          btcPrice.value = (btcData['quote']['USD']['price'] ?? 65000.0).toDouble();
        }

        // Convert to CoinItem objects
        coins.value = data.map((json) {
          return CoinItem.fromCoinMarketCap(json, btcPrice: btcPrice.value);
        }).toList();

        filteredCoins.value = coins;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to fetch coins';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void searchCoins(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredCoins.value = coins;
    } else {
      filteredCoins.value = coins.where((CoinItem coin) {
        return coin.name.toLowerCase().contains(query.toLowerCase()) ||
            coin.symbol.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredCoins.value = coins;
  }

  void selectCoin(CoinItem coin) {
    Get.back(result: coin);
  }
}
