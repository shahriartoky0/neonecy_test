// lib/features/assets/services/coin_edit_service.dart

import 'dart:convert';
 import '../../core/utils/get_storage.dart';

class CoinEditService {
  static const String _key = 'edited_coins';
  final GetStorageModel _storage = GetStorageModel();

  // Save edited coin data
  Future<void> saveCoinEdit({
    required String symbol,
    double? customPrice,
    double? customMarketCap,
  }) async {
    final Map<String, dynamic> allEdits = _getAllEdits();

    allEdits[symbol] = {
      'customPrice': customPrice,
      'customMarketCap': customMarketCap,
      'editedAt': DateTime.now().toIso8601String(),
    };

    await _storage.save(_key, jsonEncode(allEdits));
  }

  // Get edited data for a coin
  Map<String, dynamic>? getCoinEdit(String symbol) {
    final Map<String, dynamic> allEdits = _getAllEdits();
    return allEdits[symbol];
  }

  // Check if coin has custom edits
  bool hasCustomEdit(String symbol) {
    final Map<String, dynamic> allEdits = _getAllEdits();
    return allEdits.containsKey(symbol);
  }

  // Delete edit for a coin (reset to market value)
  Future<void> deleteCoinEdit(String symbol) async {
    final Map<String, dynamic> allEdits = _getAllEdits();
    allEdits.remove(symbol);
    await _storage.save(_key, jsonEncode(allEdits));
  }

  // Get all edited coins
  Map<String, dynamic> _getAllEdits() {
    final String? data = _storage.read(_key);
    if (data != null && data.isNotEmpty) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }
}