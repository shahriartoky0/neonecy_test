// lib/features/assets/controllers/coin_amount_controller.dart

import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/network/network_response.dart';
import '../../../core/utils/coin_market_service.dart';
 import '../../../core/utils/get_storage.dart';
import '../../assets/model/coin_model.dart';


class CoinAmountController extends GetxController {
  final CoinMarketCapService _coinMarketCapService = CoinMarketCapService();
  final GetStorageModel _storage = GetStorageModel();

  static const String _storageKey = 'coin_amounts';

  final RxList<CoinItem> coins = <CoinItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Store text controllers for each coin
  final Map<String, String> coinAmounts = {};

  @override
  void onInit() {
    super.onInit();
    loadCoinsFromMarket();
  }

  // Load coins from CoinMarketCap API
  Future<void> loadCoinsFromMarket() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final NetworkResponse response = await _coinMarketCapService.getLatestListings(
        limit: 20,
        sort: 'market_cap',
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final List data = response.jsonResponse!['data'] as List;
        coins.value = data.map((json) => CoinItem.fromCoinMarketCap(json)).toList();

        // Load saved amounts
        _loadSavedAmounts();
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load coins';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Load saved amounts from storage
  void _loadSavedAmounts() {
    final String? savedData = _storage.read(_storageKey);
    if (savedData != null && savedData.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(savedData);
        decoded.forEach((key, value) {
          coinAmounts[key] = value.toString();
        });
      } catch (e) {
        print('Error loading saved amounts: $e');
      }
    }
  }

  // Get saved amount for a coin (returns null if not saved)
  String? getSavedAmount(String coinId) {
    return coinAmounts[coinId];
  }

  // Update amount in memory
  void updateAmount(String coinId, String amount) {
    if (amount.isEmpty) {
      coinAmounts.remove(coinId);
    } else {
      coinAmounts[coinId] = amount;
    }
  }

  // Save all amounts to storage
  Future<void> saveAllAmounts() async {
    try {
      final Map<String, dynamic> dataToSave = {};
      coinAmounts.forEach((key, value) {
        if (value.isNotEmpty) {
          dataToSave[key] = value;
        }
      });

      await _storage.save(_storageKey, jsonEncode(dataToSave));
      Get.snackbar(
        'Success',
        'Coin amounts saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Check if coin has custom amount
  bool hasCustomAmount(String coinId) {
    return coinAmounts.containsKey(coinId) && coinAmounts[coinId]!.isNotEmpty;
  }

  // Clear all saved amounts
  Future<void> clearAllAmounts() async {
    coinAmounts.clear();
    await _storage.delete(_storageKey);
    Get.snackbar(
      'Success',
      'All amounts cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}