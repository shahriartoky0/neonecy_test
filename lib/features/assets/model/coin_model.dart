// lib/features/assets/model/coin_model.dart

class CoinItem {
  final String id;
  final int coinId;
  final String name;
  final String symbol;
  final int marketCapRank;
  final String thumb;
  final String small;
  final String large;
  final String slug;
  final double price;
  final double priceBtc;
  final String marketCap;
  final String totalVolume;
  final String sparkline;
  final double percentChange24h;

  CoinItem({
    required this.id,
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.marketCapRank,
    required this.thumb,
    required this.small,
    required this.large,
    required this.slug,
    required this.price,
    required this.priceBtc,
    required this.marketCap,
    required this.totalVolume,
    required this.sparkline,
    this.percentChange24h = 0.0,
  });

  // Original constructor for CoinGecko (keep for backwards compatibility)
  factory CoinItem.fromJson(Map<String, dynamic> json) {
    return CoinItem(
      id: json['item']['id'],
      coinId: json['item']['coin_id'],
      name: json['item']['name'],
      symbol: json['item']['symbol'],
      marketCapRank: json['item']['market_cap_rank'],
      thumb: json['item']['thumb'],
      small: json['item']['small'],
      large: json['item']['large'],
      slug: json['item']['slug'],
      price: json['item']['data']['price'],
      priceBtc: json['item']['data']['price_btc'] != null
          ? double.parse(json['item']['data']['price_btc'])
          : 0.0,
      marketCap: json['item']['data']['market_cap'],
      totalVolume: json['item']['data']['total_volume'],
      sparkline: json['item']['data']['sparkline'],
    );
  }

  // New constructor for CoinMarketCap data
  factory CoinItem.fromCoinMarketCap(Map<String, dynamic> json, {double? btcPrice}) {
    final quote = json['quote']?['USD'] ?? {};

    // Generate logo URL based on CoinMarketCap's CDN
    // Format: https://s2.coinmarketcap.com/static/img/coins/64x64/{id}.png
    final String logoUrl = 'https://s2.coinmarketcap.com/static/img/coins/64x64/${json['id']}.png';

    // Use provided BTC price or fallback
    final double currentBtcPrice = btcPrice ?? json['btc_price'] ?? 65000;

    return CoinItem(
      id: json['id'].toString(),
      coinId: json['id'] ?? 0,
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      marketCapRank: json['cmc_rank'] ?? 0,
      thumb: logoUrl,
      small: logoUrl,
      large: logoUrl,
      slug: json['slug'] ?? '',
      price: (quote['price'] ?? 0.0).toDouble(),
      priceBtc: _calculateBtcPrice(quote['price'], json['symbol'], currentBtcPrice),
      marketCap: _formatLargeNumber(quote['market_cap']),
      totalVolume: _formatLargeNumber(quote['volume_24h']),
      sparkline: '', // CoinMarketCap doesn't provide sparkline in basic endpoint
      percentChange24h: (quote['percent_change_24h'] ?? 0.0).toDouble(),
    );
  }

  // Helper method to calculate BTC price
  static double _calculateBtcPrice(dynamic usdPrice, String symbol, double btcPrice) {
    // If it's BTC itself, return 1
    if (symbol == 'BTC') return 1.0;

    // For other coins, divide by actual BTC price
    return (usdPrice ?? 0.0) / btcPrice;
  }

  // Helper method to format large numbers
  static String _formatLargeNumber(dynamic number) {
    if (number == null) return 'N/A';

    double value = number is double ? number : number.toDouble();

    if (value >= 1e12) {
      return '\$${(value / 1e12).toStringAsFixed(2)}T';
    } else if (value >= 1e9) {
      return '\$${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '\$${(value / 1e6).toStringAsFixed(2)}M';
    } else if (value >= 1e3) {
      return '\$${(value / 1e3).toStringAsFixed(2)}K';
    } else {
      return '\$${value.toStringAsFixed(2)}';
    }
  }
}

class CoinData {
  final CoinItem item;

  CoinData({required this.item});

  factory CoinData.fromJson(Map<String, dynamic> json) {
    return CoinData(
      item: CoinItem.fromJson(json),
    );
  }
}