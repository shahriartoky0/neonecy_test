import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/network/network_response.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';
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

  // Fetch coin data (list of all coins)
  fetchCoinData() async {
    isLoadingBottomTab.value = true; // Show loading indicator

    try {
      final CoinGeckoService _geckoService = CoinGeckoService();
      final NetworkResponse response = await _geckoService.getTrendingCoins();

      // Save all coins into coinItems, iterating through the "coins" list and accessing the "item" map
      coinItems.value = List<CoinItem>.from(
        response.jsonResponse?['coins'].map((coinJson) => CoinItem.fromJson(coinJson['item'])),
      );

      LoggerUtils.debug(response.jsonResponse); // Log the response
    } catch (e) {
      // Handle error case
      LoggerUtils.error('Failed to fetch coin data: $e');
    } finally {
      isLoadingBottomTab.value = false; // Hide loading indicator
    }
  }
}
