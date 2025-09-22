import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../model/enhanced_crypto_data_model.dart';
import '../widget/enhanced_crupto.dart';

class EnhancedCryptoMarketController extends GetxController {
  // Tab management
  final RxList<String> tabs = <String>['All', 'Holdings', 'Spot', 'Alpha', 'Futures', 'Option'].obs;
  final RxInt selectedTab = 0.obs;

  // Crypto data
  final RxList<EnhancedCryptoData> _allCryptoList = <EnhancedCryptoData>[].obs;
  final RxList<EnhancedCryptoData> cryptoList = <EnhancedCryptoData>[].obs;

  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Search functionality
  final RxString searchQuery = ''.obs;

  // Sorting
  final RxString sortBy = 'symbol'.obs; // symbol, price, change, volume
  final RxBool isAscending = true.obs;

  // Favorites
  final RxList<String> favoriteSymbols = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeMockData();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    searchQuery.listen((_) => _filterCryptoList());
  }

  void _initializeMockData() {
    _allCryptoList.assignAll(<EnhancedCryptoData>[
      EnhancedCryptoData(
        symbol: 'BNB',
        name: 'Binance Coin',
        price: 643.66,
        changePercent: -1.49,
        volume: 91210000,
        leverage: '10x',
      ),
      EnhancedCryptoData(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 104646.02,
        changePercent: -0.99,
        volume: 1660000,
        leverage: '10x',
      ),
      EnhancedCryptoData(
        symbol: 'ETH',
        name: 'Ethereum',
        price: 643.66,
        changePercent: -1.92,
        volume: 1470000,
        leverage: '10x',
      ),
      EnhancedCryptoData(
        symbol: 'SOL',
        name: 'Solana',
        price: 145.70,
        changePercent: -3.36,
        volume: 407700000,
        leverage: '5x',
      ),
      EnhancedCryptoData(
        symbol: 'PEPE',
        name: 'Pepe',
        price: 0.00001005,
        changePercent: -3.74,
        volume: 160200000,
        leverage: '5x',
      ),
      EnhancedCryptoData(
        symbol: 'KMNO',
        name: 'Kimono',
        price: 0.06715,
        changePercent: -1.25,
        volume: 2300000,
        leverage: '5x',
      ),
    ]);

    cryptoList.assignAll(_allCryptoList);
  }

  // Tab selection
  void selectTab(int index) {
    selectedTab.value = index;
    _filterByTab();
  }

  void _filterByTab() {
    switch (selectedTab.value) {
      case 0: // All
        _allCryptoList.assignAll(_getMockDataForTab('all'));
        break;
      case 1: // Holdings
        _allCryptoList.assignAll(_getMockDataForTab('holdings'));
        break;
      case 2: // Spot
        _allCryptoList.assignAll(_getMockDataForTab('spot'));
        break;
      case 3: // Alpha
        _allCryptoList.assignAll(_getMockDataForTab('alpha'));
        break;
      case 4: // Futures
        _allCryptoList.assignAll(_getMockDataForTab('futures'));
        break;
      case 5: // Option
        _allCryptoList.assignAll(_getMockDataForTab('option'));
        break;
    }
    _filterCryptoList();
  }

  List<EnhancedCryptoData> _getMockDataForTab(String tab) {
    // This is where you would fetch different data based on the tab
    // For now, returning the same mock data with slight variations
    final List<EnhancedCryptoData> baseData = <EnhancedCryptoData>[
      EnhancedCryptoData(
        symbol: 'BNB',
        name: 'Binance Coin',
        price: 643.66,
        changePercent: -1.49,
        volume: 91210000,
        leverage: '10x',
      ),
      EnhancedCryptoData(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: 104646.02,
        changePercent: -0.99,
        volume: 1660000,
        leverage: '10x',
      ),
      EnhancedCryptoData(
        symbol: 'ETH',
        name: 'Ethereum',
        price: 643.66,
        changePercent: -1.92,
        volume: 1470000,
        leverage: '10x',
      ),
      EnhancedCryptoData(
        symbol: 'SOL',
        name: 'Solana',
        price: 145.70,
        changePercent: -3.36,
        volume: 407700000,
        leverage: '5x',
      ),
      EnhancedCryptoData(
        symbol: 'PEPE',
        name: 'Pepe',
        price: 0.00001005,
        changePercent: -3.74,
        volume: 160200000,
        leverage: '5x',
      ),
      EnhancedCryptoData(
        symbol: 'KMNO',
        name: 'Kimono',
        price: 0.06715,
        changePercent: -1.25,
        volume: 2300000,
        leverage: '5x',
      ),
    ];

    switch (tab) {
      case 'holdings':
        return baseData.where((EnhancedCryptoData crypto) => favoriteSymbols.contains(crypto.symbol)).toList();
      case 'spot':
        return baseData.where((EnhancedCryptoData crypto) => crypto.leverage == '10x').toList();
      case 'futures':
        return baseData.where((EnhancedCryptoData crypto) => crypto.leverage == '5x').toList();
      default:
        return baseData;
    }
  }

  // Search functionality
  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void _filterCryptoList() {
    List<EnhancedCryptoData> filteredList = _allCryptoList.where((EnhancedCryptoData crypto) {
      return crypto.symbol.toLowerCase().contains(searchQuery.value) ||
          crypto.name.toLowerCase().contains(searchQuery.value);
    }).toList();

    // Apply sorting
    _sortCryptoList(filteredList);
    cryptoList.assignAll(filteredList);
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
          comparison = a.symbol.compareTo(b.symbol);
      }

      return isAscending.value ? comparison : -comparison;
    });
  }

  // Favorites functionality
  void toggleFavorite(String symbol) {
    if (favoriteSymbols.contains(symbol)) {
      favoriteSymbols.remove(symbol);
    } else {
      favoriteSymbols.add(symbol);
    }

    // Update the crypto data to reflect favorite status
    final int index = _allCryptoList.indexWhere((EnhancedCryptoData crypto) => crypto.symbol == symbol);
    if (index != -1) {
      _allCryptoList[index] = _allCryptoList[index].copyWith(
        isFavorite: favoriteSymbols.contains(symbol),
      );
    }

    _filterCryptoList();
  }

  bool isFavorite(String symbol) {
    return favoriteSymbols.contains(symbol);
  }

  // Data refresh functionality
  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call your API here
      // final response = await cryptoApiService.getCryptoData();

      // Update with fresh mock data for demo
      _initializeMockData();
      _filterByTab();

    } catch (e) {
      errorMessage.value = 'Failed to refresh data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Utility methods
  String getTabName(int index) {
    return index < tabs.length ? tabs[index] : 'Unknown';
  }

  int get totalCryptoCount => _allCryptoList.length;
  int get visibleCryptoCount => cryptoList.length;

  // Cleanup
  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}