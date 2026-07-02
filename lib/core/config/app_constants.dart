class AppConstants {
  AppConstants._();

  static const String token = "token";
  static const String balanceText = "balance-text";
  static const String switchValue = "switch-value";
  static const String usernameKey = 'user_name';
  static const String binanceIdKey = 'binance_id';
  static const String profileImageKey = 'profile_image';
  static const String tradeFromCoin = 'trade_from_coin';
  static const String tradeToCoin = 'trade_to_coin';
  static const String lastLoginAt = 'last_login_at';

  /// Identifier (email/phone) of the last successful login. Intentionally
  /// survives logOut() so the login field can stay prepopulated.
  static const String lastLoginEmail = 'last_login_email';
}
