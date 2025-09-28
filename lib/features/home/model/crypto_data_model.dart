class CryptoData {
  final String symbol;
  final double price;
  final String formattedPrice;
  final double changePercent;
  final String? name;
  final double? marketCap;
  final double? volume;
  final String? imageUrl;
  final String? subText;


  CryptoData({
    required this.symbol,
    required this.price,
    required this.formattedPrice,
    required this.changePercent,
    this.name,
    this.marketCap,
    this.volume,
    this.imageUrl,
    this.subText,
  });

  // Factory constructor from CoinGecko API response
  factory CryptoData.fromCoinGecko(Map<String, dynamic> json) {
    return CryptoData(
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      price: (json['current_price'] ?? 0.0).toDouble(),
      formattedPrice: _formatPrice(json['current_price'] ?? 0.0),
      changePercent: (json['price_change_percentage_24h'] ?? 0.0).toDouble(),
      name: json['name'],
      marketCap: json['market_cap']?.toDouble(),
      volume: json['total_volume']?.toDouble(),
      imageUrl: json['image'],
    );
  }

  // Factory constructor from trending coins API response
  factory CryptoData.fromTrendingCoin(Map<String, dynamic> trendingItem, Map<String, dynamic>? priceData) {
    final item = trendingItem['item'] ?? trendingItem;
    return CryptoData(
      symbol: (item['symbol'] ?? '').toString().toUpperCase(),
      price: priceData != null ? (priceData['usd'] ?? 0.0).toDouble() : 0.0,
      formattedPrice: priceData != null ? _formatPrice(priceData['usd'] ?? 0.0) : 'N/A',
      changePercent: priceData != null ? (priceData['usd_24h_change'] ?? 0.0).toDouble() : 0.0,
      name: item['name'],
      marketCap: priceData?['usd_market_cap']?.toDouble(),
      volume: priceData?['usd_24h_vol']?.toDouble(),
      imageUrl: item['large'] ?? item['thumb'],
    );
  }

  static String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      );
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(6);
    }
  }

  // Getters for formatted display
  String get formattedMarketCap {
    if (marketCap == null) return 'N/A';
    if (marketCap! >= 1e9) {
      return '\$${(marketCap! / 1e9).toStringAsFixed(1)}B';
    } else if (marketCap! >= 1e6) {
      return '\$${(marketCap! / 1e6).toStringAsFixed(1)}M';
    } else {
      return '\$${marketCap!.toStringAsFixed(0)}';
    }
  }

  String get formattedVolume {
    if (volume == null) return 'N/A';
    if (volume! >= 1e9) {
      return '\$${(volume! / 1e9).toStringAsFixed(1)}B';
    } else if (volume! >= 1e6) {
      return '\$${(volume! / 1e6).toStringAsFixed(1)}M';
    } else {
      return '\$${volume!.toStringAsFixed(0)}';
    }
  }

  String get formattedChangePercent {
    return '${changePercent > 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
  }

  bool get isPositiveChange => changePercent >= 0;
}