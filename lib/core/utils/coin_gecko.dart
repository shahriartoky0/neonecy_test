import '../network/network_caller.dart';
import '../network/network_response.dart';


// Add these methods to your CoinGeckoService if they're missing

class CoinGeckoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';
  final NetworkCaller _networkCaller = NetworkCaller();

  // Get trending coins
  Future<NetworkResponse> getTrendingCoins() async {
    const String url = '$baseUrl/search/trending';
    return await _networkCaller.getRequest(url);
  }

  // Get top coins with pagination support
  Future<NetworkResponse> getTopCoins({
    String vsCurrency = 'usd',
    int perPage = 100,
    int page = 1,
  }) async {
    final String url = '$baseUrl/coins/markets?vs_currency=$vsCurrency&per_page=$perPage&page=$page&order=market_cap_desc';
    return await _networkCaller.getRequest(url);
  }

  // Get coin price by ID
  Future<NetworkResponse> getCoinPrice({
    required String coinId,
    String vsCurrency = 'usd',
    bool includeMarketCap = false,
    bool include24hrVol = false,
    bool include24hrChange = false,
  }) async {
    String params = 'ids=$coinId&vs_currencies=$vsCurrency';
    if (includeMarketCap) {
      params += '&include_market_cap=true';
    }
    if (include24hrVol) {
      params += '&include_24hr_vol=true';
    }
    if (include24hrChange) {
      params += '&include_24hr_change=true';
    }

    final String url = '$baseUrl/simple/price?$params';
    return await _networkCaller.getRequest(url);
  }

  // Get multiple coins price
  Future<NetworkResponse> getMultipleCoinsPrice({
    required List<String> coinIds,
    String vsCurrency = 'usd',
  }) async {
    final String ids = coinIds.join(',');
    final String url = '$baseUrl/simple/price?ids=$ids&vs_currencies=$vsCurrency&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true';
    return await _networkCaller.getRequest(url);
  }

  // Search coins
  Future<NetworkResponse> searchCoins({required String query}) async {
    final String url = '$baseUrl/search?query=$query';
    return await _networkCaller.getRequest(url);
  }
}