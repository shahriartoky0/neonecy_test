
import '../network/network_caller.dart';
import '../network/network_response.dart';
import 'logger_utils.dart';

class CoinMarketCapService {
  // Note: You need to get your own API key from https://coinmarketcap.com/api/
  // Free tier gives you 10,000 calls per month
  static const String apiKey = '84c76642-66bd-4ea5-b187-da34bc4f1f3c'; // Replace with your actual API key
  static const String baseUrl = 'https://pro-api.coinmarketcap.com/v1';

  final NetworkCaller _networkCaller = NetworkCaller();

  Map<String, String> get _headers => <String, String>{
    'X-CMC_PRO_API_KEY': apiKey,
    'Accept': 'application/json',
  };

  // Get latest listings
  Future<NetworkResponse> getLatestListings({
    int start = 1,
    int limit = 100,
    String convert = 'USD',
    String sort = 'market_cap', // market_cap, name, symbol, date_added, market_cap_strict, price, circulating_supply, total_supply, max_supply, num_market_pairs, volume_24h, percent_change_1h, percent_change_24h, percent_change_7d
    String sortDir = 'desc', // asc or desc
  }) async {
    try {
      final String url = '$baseUrl/cryptocurrency/listings/latest'
          '?start=$start'
          '&limit=$limit'
          '&convert=$convert'
          '&sort=$sort'
          '&sort_dir=$sortDir';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: _headers,
      );

      LoggerUtils.debug('CMC Latest listings response: ${response.statusCode}');
      return response;
    } catch (e) {
      LoggerUtils.debug('Error fetching CMC latest listings: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Get trending cryptocurrencies
  Future<NetworkResponse> getTrending({
    int limit = 10,
    String convert = 'USD',
    String timePeriod = '24h', // 24h, 7d, 30d
  }) async {
    try {
      final String url = '$baseUrl/cryptocurrency/trending/latest'
          '?limit=$limit'
          '&convert=$convert'
          '&time_period=$timePeriod';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: _headers,
      );

      LoggerUtils.debug('CMC Trending response: ${response.statusCode}');
      return response;
    } catch (e) {
      LoggerUtils.debug('Error fetching CMC trending: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Get top gainers
  Future<NetworkResponse> getTopGainers({
    int limit = 10,
    String convert = 'USD',
    String timePeriod = '24h',
  }) async {
    try {
      final String url = '$baseUrl/cryptocurrency/trending/gainers-losers'
          '?limit=$limit'
          '&convert=$convert'
          '&time_period=$timePeriod'
          '&sort_dir=desc';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: _headers,
      );

      LoggerUtils.debug('CMC Top gainers response: ${response.statusCode}');
      return response;
    } catch (e) {
      LoggerUtils.debug('Error fetching CMC top gainers: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Get newly added cryptocurrencies
  Future<NetworkResponse> getNewListings({
    int limit = 10,
    String convert = 'USD',
  }) async {
    try {
      // Get latest listings sorted by date_added
      final String url = '$baseUrl/cryptocurrency/listings/latest'
          '?start=1'
          '&limit=$limit'
          '&convert=$convert'
          '&sort=date_added'
          '&sort_dir=desc';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: _headers,
      );

      LoggerUtils.debug('CMC New listings response: ${response.statusCode}');
      return response;
    } catch (e) {
      LoggerUtils.debug('Error fetching CMC new listings: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Get quotes for specific cryptocurrencies
  Future<NetworkResponse> getQuotes({
    required List<String> symbols,
    String convert = 'USD',
  }) async {
    try {
      final String symbolList = symbols.join(',');
      final String url = '$baseUrl/cryptocurrency/quotes/latest'
          '?symbol=$symbolList'
          '&convert=$convert';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: _headers,
      );

      LoggerUtils.debug('CMC Quotes response: ${response.statusCode}');
      return response;
    } catch (e) {
      LoggerUtils.debug('Error fetching CMC quotes: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

  // Get global metrics
  Future<NetworkResponse> getGlobalMetrics({
    String convert = 'USD',
  }) async {
    try {
      final String url = '$baseUrl/global-metrics/quotes/latest'
          '?convert=$convert';

      final NetworkResponse response = await _networkCaller.getRequest(
        url,
        headers: _headers,
      );

      LoggerUtils.debug('CMC Global metrics response: ${response.statusCode}');
      return response;
    } catch (e) {
      LoggerUtils.debug('Error fetching CMC global metrics: $e');
      return NetworkResponse(isSuccess: false, errorMessage: e.toString());
    }
  }

}

