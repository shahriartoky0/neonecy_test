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
  });

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
      priceBtc: json['item']['data']['price_btc'] != null ? double.parse(json['item']['data']['price_btc']) : 0.0,
      marketCap: json['item']['data']['market_cap'],
      totalVolume: json['item']['data']['total_volume'],
      sparkline: json['item']['data']['sparkline'],
    );
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
