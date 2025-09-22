// Enhanced Crypto Data Model
class EnhancedCryptoData {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double volume;
  final String leverage;
  final bool isFavorite;

  EnhancedCryptoData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.volume,
    this.leverage = '10x',
    this.isFavorite = false,
  });

  String get formattedPrice {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(8);
    }
  }

  String get formattedVolume {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    } else {
      return volume.toStringAsFixed(2);
    }
  }

  String get changePercentFormatted {
    final String sign = changePercent > 0 ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  // Copy with method for updates
  EnhancedCryptoData copyWith({
    String? symbol,
    String? name,
    double? price,
    double? changePercent,
    double? volume,
    String? leverage,
    bool? isFavorite,
  }) {
    return EnhancedCryptoData(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      volume: volume ?? this.volume,
      leverage: leverage ?? this.leverage,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}