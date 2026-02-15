// lib/features/wallet/models/coin_wallet_model.dart
import '../../assets/model/coin_model.dart';

class WalletCoinModel {
  final CoinItem coinDetails;
  final double quantity;
  final double averagePurchasePrice;

  WalletCoinModel({
    required this.coinDetails,
    required this.quantity,
    required this.averagePurchasePrice,
  });

  // Calculate current value
  double get currentValue => quantity * coinDetails.price;

  // Calculate invested value
  double get investedValue => quantity * averagePurchasePrice;

  // Calculate profit/loss
  double get profitLoss => currentValue - investedValue;

  // Calculate profit/loss percentage
  double get profitLossPercent {
    if (investedValue == 0) return 0.0;
    return (profitLoss / investedValue) * 100;
  }

  // Check if in profit
  bool get isInProfit => profitLoss >= 0;

  // Convert to JSON for storage (only store essential data)
  Map<String, dynamic> toJson() {
    return {
      'coinId': coinDetails.coinId,
      'name': coinDetails.name,
      'symbol': coinDetails.symbol,
      'marketCapRank': coinDetails.marketCapRank,
      'thumb': coinDetails.thumb,
      'small': coinDetails.small,
      'large': coinDetails.large,
      'slug': coinDetails.slug,
      'quantity': quantity,
      'averagePurchasePrice': averagePurchasePrice,
    };
  }

  // Create from JSON
  factory WalletCoinModel.fromJson(
      Map<String, dynamic> json,
      CoinItem updatedCoinDetails,
      ) {
    return WalletCoinModel(
      coinDetails: updatedCoinDetails,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      averagePurchasePrice: (json['averagePurchasePrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Update coin with new values
  WalletCoinModel updateCoin({
    double? newQuantity,
    double? newAveragePurchasePrice,
  }) {
    return WalletCoinModel(
      coinDetails: coinDetails,
      quantity: newQuantity ?? quantity,
      averagePurchasePrice: newAveragePurchasePrice ?? averagePurchasePrice,
    );
  }

  // Copy with method for updating coin details while keeping investment data
  WalletCoinModel copyWith({
    CoinItem? coinDetails,
    double? quantity,
    double? averagePurchasePrice,
  }) {
    return WalletCoinModel(
      coinDetails: coinDetails ?? this.coinDetails,
      quantity: quantity ?? this.quantity,
      averagePurchasePrice: averagePurchasePrice ?? this.averagePurchasePrice,
    );
  }
}