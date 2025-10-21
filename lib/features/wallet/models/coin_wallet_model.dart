// lib/features/wallet/models/wallet_coin_model.dart
import '../../../core/network/network_response.dart';
import '../../assets/model/coin_model.dart';

class WalletCoinModel {
  final CoinItem coinDetails;
  final double quantity;
  final double averagePurchasePrice;
  final DateTime purchaseDate;

  WalletCoinModel({
    required this.coinDetails,
    required this.quantity,
    required this.averagePurchasePrice,
    DateTime? purchaseDate,
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  // Calculate total investment
  double get totalInvestment => quantity * averagePurchasePrice;

  // Calculate current value based on market price
  double get currentValue => quantity * coinDetails.price;

  // Calculate profit/loss percentage
  double get profitLossPercentage {
    if (totalInvestment == 0) return 0.0;
    return ((currentValue - totalInvestment) / totalInvestment) * 100;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'coinId': coinDetails.id,
      'symbol': coinDetails.symbol,
      'quantity': quantity,
      'averagePurchasePrice': averagePurchasePrice,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
  }

  // Create from JSON (used when retrieving from storage)
  factory WalletCoinModel.fromJson(Map<String, dynamic> json, CoinItem coinDetails) {
    return WalletCoinModel(
      coinDetails: coinDetails,
      quantity: json['quantity'] ?? 0.0,
      averagePurchasePrice: json['averagePurchasePrice'] ?? 0.0,
      purchaseDate: DateTime.parse(json['purchaseDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to update coin quantity and average purchase price
  WalletCoinModel updateCoin({
    double? newQuantity,
    double? newAveragePurchasePrice,
  }) {
    return WalletCoinModel(
      coinDetails: coinDetails,
      quantity: newQuantity ?? quantity,
      averagePurchasePrice: newAveragePurchasePrice ?? averagePurchasePrice,
      purchaseDate: purchaseDate,
    );
  }
}