
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
  final double priceBtc;
  final CoinData data;

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
    required this.priceBtc,
    required this.data,
  });

  factory CoinItem.fromJson(Map<String, dynamic> json) {
    return CoinItem(
      id: json['id'],
      coinId: json['coin_id'],
      name: json['name'],
      symbol: json['symbol'],
      marketCapRank: json['market_cap_rank'],
      thumb: json['thumb'],
      small: json['small'],
      large: json['large'],
      slug: json['slug'],
      priceBtc: json['price_btc'].toDouble(),
      data: CoinData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coin_id': coinId,
      'name': name,
      'symbol': symbol,
      'market_cap_rank': marketCapRank,
      'thumb': thumb,
      'small': small,
      'large': large,
      'slug': slug,
      'price_btc': priceBtc,
      'data': data.toJson(),
    };
  }
}

class CoinData {
  final double price;
  final String marketCap;
  final String marketCapBtc;
  final String totalVolume;
  final String totalVolumeBtc;
  final String sparkline;

  CoinData({
    required this.price,
    required this.marketCap,
    required this.marketCapBtc,
    required this.totalVolume,
    required this.totalVolumeBtc,
    required this.sparkline,
  });

  factory CoinData.fromJson(Map<String, dynamic> json) {
    return CoinData(
      price: json['price'].toDouble(),
      marketCap: json['market_cap'],
      marketCapBtc: json['market_cap_btc'],
      totalVolume: json['total_volume'],
      totalVolumeBtc: json['total_volume_btc'],
      sparkline: json['sparkline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'market_cap': marketCap,
      'market_cap_btc': marketCapBtc,
      'total_volume': totalVolume,
      'total_volume_btc': totalVolumeBtc,
      'sparkline': sparkline,
    };
  }
}

