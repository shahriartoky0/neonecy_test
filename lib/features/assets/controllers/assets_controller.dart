import 'package:get/get.dart';
import 'package:neonecy_test/core/network/network_response.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';
import 'package:neonecy_test/features/home/controllers/home_controller.dart';
import '../../../core/utils/coin_gecko.dart';
import '../model/coin_model.dart';

class AssetsController extends GetxController with GetSingleTickerProviderStateMixin {
  /// ====> For the lower tabs
  RxString selectedBottomTab = 'Crypto'.obs;

  // Reactive list to store all coins
  RxList<CoinItem> coinItems = <CoinItem>[].obs; // Stores all coins

  // To handle loading state
  RxBool isLoadingBottomTab = false.obs;

  void selectBottomTab(String tab) {
    selectedBottomTab.value = tab;
  }

  void onEarnTap() {
    print('Earn tapped');
    // Add earn functionality
  }

  void onTradeTap() {
    print('Trade tapped');
    // Add trade functionality
  }

  @override
  Future<void> onInit() async {
    await fetchCoinData();
    super.onInit();
  }

  ///===============>  for <1 USD items ===========>
  RxBool lessThanDollarItems = false.obs;

  void filterAssetsBasedOnPrice() {
    if (lessThanDollarItems.value) {
      // If 'isHiddenAsset' is true, filter coins less than 1 USD
      coinItems.value = coinItems.where((CoinItem coin) => coin.price >= 1).toList();
    } else {
      // If 'isHiddenAsset' is false, keep all coins
      fetchCoinData(); // Re-fetch coins if necessary (optional based on your use case)
    }
  }

  // Method to toggle 'isHiddenAsset' when checkbox state changes
  void toggleHideAssets() {
    lessThanDollarItems.value = !lessThanDollarItems.value;
    filterAssetsBasedOnPrice(); // Reapply the filter based on new state
  }

  ///===============>  Fetch coin data (list of all coins)
  final RxBool isLoadingCoin = false.obs;
  RxBool inRefresh = false.obs;

  Future<void> onRefresh() async {
    try {
      inRefresh.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 1600));

      fetchCoinData();

      /// === for the balance === >
      Get.find<HomeController>().fetchAndSetTheBalance();
    } catch (e) {
      LoggerUtils.error(e);
    } finally {
      inRefresh.value = false;
    }
  }

  Future<void> fetchCoinData() async {
    isLoadingCoin.value = true; // Show loading indicator
    try {
      final CoinGeckoService _geckoService = CoinGeckoService();
      final NetworkResponse response = await _geckoService.getTrendingCoins();
      // Check if the response is valid and contains coin data
      if (response.isSuccess && response.jsonResponse != null) {
        // Assuming the response is a list of coins (adjust according to actual structure)
        List<dynamic> coinList = response.jsonResponse?['coins'];
        // LoggerUtils.debug(coinList);

        // Map the response data into a list of CoinItem objects
        coinItems.value = coinList.map((dynamic coinJson) => CoinItem.fromJson(coinJson)).toList();

        // LoggerUtils.debug('Successfully fetched and parsed coin data${coinItems[0]}');
      } else {
        LoggerUtils.error('Error: Response was not successful');
      }
    } catch (e) {
      // Handle any errors (e.g., network errors)
      LoggerUtils.error('Failed to fetch coin data: $e');
    } finally {
      isLoadingCoin.value = false;
    }
  }
}
