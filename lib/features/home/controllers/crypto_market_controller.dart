import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../model/crypto_data_model.dart';

class CryptoMarketController extends GetxController {
  RxInt selectedTab = 2.obs; // Default to "Losers"
  RxList<CryptoData> cryptoList = <CryptoData>[].obs;

  final List<String> tabs = <String>['New', 'Gainers', 'Losers', '24h Vol', 'Mark'];
  final List<String> categories = <String>['Crypto', 'Spot', 'Futures'];
  RxInt selectedCategory = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDemoData();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    loadDemoData();
  }

  void selectCategory(int index) {
    selectedCategory.value = index;
  }

  void loadDemoData() {
    // Demo data based on selected tab
    switch (selectedTab.value) {
      case 0: // New
        cryptoList.value = <CryptoData>[
          CryptoData(
            symbol: 'PEPE',
            price: 0.000012,
            formattedPrice: '0.000012',
            changePercent: 45.67,
          ),
          CryptoData(
            symbol: 'SHIB',
            price: 0.000008,
            formattedPrice: '0.000008',
            changePercent: 23.45,
          ),
          CryptoData(symbol: 'DOGE', price: 0.062, formattedPrice: '0.062', changePercent: 12.34),
        ];
        break;
      case 1: // Gainers
        cryptoList.value = <CryptoData>[
          CryptoData(symbol: 'BTC', price: 67890, formattedPrice: '67,890', changePercent: 8.45),
          CryptoData(symbol: 'ETH', price: 3456, formattedPrice: '3,456', changePercent: 6.78),
          CryptoData(symbol: 'BNB', price: 345, formattedPrice: '345', changePercent: 4.32),
        ];
        break;
      case 2: // Losers (default)
        cryptoList.value = <CryptoData>[
          CryptoData(symbol: 'ASR', price: 3.000, formattedPrice: '3.000', changePercent: -15.04),
          CryptoData(symbol: 'API3', price: 1.334, formattedPrice: '1.334', changePercent: -14.32),
          CryptoData(
            symbol: 'UTK',
            price: 0.03214,
            formattedPrice: '0.03214',
            changePercent: -12.31,
          ),
          CryptoData(
            symbol: 'DATA',
            price: 0.01531,
            formattedPrice: '0.01531',
            changePercent: -11.25,
          ),
        ];
        break;
      case 3: // 24h Vol
        cryptoList.value = <CryptoData>[
          CryptoData(symbol: 'BTC', price: 67890, formattedPrice: '67,890', changePercent: 2.45),
          CryptoData(symbol: 'ETH', price: 3456, formattedPrice: '3,456', changePercent: -1.23),
          CryptoData(symbol: 'USDT', price: 1.0, formattedPrice: '1.000', changePercent: 0.01),
        ];
        break;
      case 4: // Mark
        cryptoList.value = <CryptoData>[
          CryptoData(symbol: 'SOL', price: 123.45, formattedPrice: '123.45', changePercent: 3.21),
          CryptoData(symbol: 'ADA', price: 0.456, formattedPrice: '0.456', changePercent: -2.15),
          CryptoData(symbol: 'DOT', price: 6.789, formattedPrice: '6.789', changePercent: 1.87),
        ];
        break;
    }
  }
}
