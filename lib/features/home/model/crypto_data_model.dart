class CryptoData {
  final String symbol;
  final double price;
  final String formattedPrice;
  final double changePercent;

  CryptoData({
    required this.symbol,
    required this.price,
    required this.formattedPrice,
    required this.changePercent,
  });
}