// lib/core/services/address_storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../../features/settings/model/crypto_address_model.dart';

class AddressStorageService {
  static const String _addressesKey = 'crypto_addresses';
  static const String _depositHistoryKey = 'deposit_history';
  static const String _withdrawHistoryKey = 'withdraw_history';

  final GetStorage _storage = GetStorage();

  // ══════════════════════════════════════════════════════════════════════════
  // DEPOSIT HISTORY
  // ══════════════════════════════════════════════════════════════════════════

  List<String> getRecentDepositSymbols() {
    final dynamic data = _storage.read(_depositHistoryKey);
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  void addToDepositHistory(String symbol) {
    final history = getRecentDepositSymbols();
    history.remove(symbol);
    history.insert(0, symbol);
    _storage.write(_depositHistoryKey, history.take(6).toList());
    print('📥 Added $symbol to deposit history');
  }

  void clearDepositHistory() {
    _storage.write(_depositHistoryKey, <String>[]);
    print('🧹 Cleared deposit history');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // WITHDRAW HISTORY
  // ══════════════════════════════════════════════════════════════════════════

  List<String> getRecentWithdrawSymbols() {
    final dynamic data = _storage.read(_withdrawHistoryKey);
    if (data == null) return [];
    return List<String>.from(data as List);
  }

  void addToWithdrawHistory(String symbol) {
    final history = getRecentWithdrawSymbols();
    history.remove(symbol);
    history.insert(0, symbol);
    _storage.write(_withdrawHistoryKey, history.take(6).toList());
    print('📤 Added $symbol to withdraw history');
  }

  void clearWithdrawHistory() {
    _storage.write(_withdrawHistoryKey, <String>[]);
    print('🧹 Cleared withdraw history');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADDRESS CRUD OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Save all addresses
  Future<void> saveAddresses(List<CryptoAddressModel> addresses) async {
    final List<Map<String, dynamic>> addressesJson =
    addresses.map((addr) => addr.toJson()).toList();
    await _storage.write(_addressesKey, addressesJson);
    print('💾 Saved ${addresses.length} addresses to storage');
  }

  /// Load all addresses
  List<CryptoAddressModel> loadAddresses() {
    final dynamic addressesData = _storage.read(_addressesKey);

    if (addressesData == null) {
      print('📭 No addresses found in storage');
      return [];
    }

    try {
      final List<dynamic> addressesList = addressesData as List<dynamic>;
      final List<CryptoAddressModel> addresses = addressesList
          .map((json) => CryptoAddressModel.fromJson(json as Map<String, dynamic>))
          .toList();

      print('📬 Loaded ${addresses.length} addresses from storage');
      return addresses;
    } catch (e) {
      print('❌ Error loading addresses: $e');
      return [];
    }
  }

  /// Get addresses for specific coin
  List<CryptoAddressModel> getAddressesForCoin(String coinSymbol) {
    final List<CryptoAddressModel> allAddresses = loadAddresses();
    final List<CryptoAddressModel> coinAddresses = allAddresses
        .where((addr) => addr.coinSymbol.toUpperCase() == coinSymbol.toUpperCase())
        .toList();

    print('🪙 Found ${coinAddresses.length} addresses for $coinSymbol');
    return coinAddresses;
  }

  /// Get addresses for specific coin and network
  List<CryptoAddressModel> getAddressesForCoinAndNetwork(
      String coinSymbol, String network) {
    final List<CryptoAddressModel> coinAddresses = getAddressesForCoin(coinSymbol);
    final List<CryptoAddressModel> networkAddresses = coinAddresses
        .where((addr) => addr.network.toUpperCase() == network.toUpperCase())
        .toList();

    print('🌐 Found ${networkAddresses.length} addresses for $coinSymbol on $network');
    return networkAddresses;
  }

  /// Add new address
  Future<void> addAddress(CryptoAddressModel newAddress) async {
    final List<CryptoAddressModel> addresses = loadAddresses();

    // If this is the first address for this coin+network, make it default
    final bool hasExisting = addresses.any((addr) =>
    addr.coinSymbol.toUpperCase() == newAddress.coinSymbol.toUpperCase() &&
        addr.network.toUpperCase() == newAddress.network.toUpperCase());

    final CryptoAddressModel addressToAdd = hasExisting
        ? newAddress
        : newAddress.copyWith(isDefault: true);

    addresses.add(addressToAdd);
    await saveAddresses(addresses);
    print('✅ Added new address for ${newAddress.coinSymbol} on ${newAddress.network}');
  }

  /// Update address
  Future<void> updateAddress(CryptoAddressModel updatedAddress) async {
    final List<CryptoAddressModel> addresses = loadAddresses();
    final int index = addresses.indexWhere((addr) => addr.id == updatedAddress.id);

    if (index != -1) {
      addresses[index] = updatedAddress;
      await saveAddresses(addresses);
      print('🔄 Updated address ${updatedAddress.id}');
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    final List<CryptoAddressModel> addresses = loadAddresses();
    addresses.removeWhere((addr) => addr.id == addressId);
    await saveAddresses(addresses);
    print('🗑️ Deleted address $addressId');
  }

  /// Set address as default for its coin+network
  Future<void> setAsDefault(String addressId) async {
    final List<CryptoAddressModel> addresses = loadAddresses();

    // Find the address to set as default
    final CryptoAddressModel? targetAddress = addresses.firstWhereOrNull(
          (addr) => addr.id == addressId,
    );

    if (targetAddress == null) return;

    // Update all addresses
    final List<CryptoAddressModel> updatedAddresses = addresses.map((addr) {
      if (addr.id == addressId) {
        // Set this as default
        return addr.copyWith(isDefault: true);
      } else if (addr.coinSymbol == targetAddress.coinSymbol &&
          addr.network == targetAddress.network &&
          addr.isDefault) {
        // Remove default from other addresses with same coin+network
        return addr.copyWith(isDefault: false);
      }
      return addr;
    }).toList();

    await saveAddresses(updatedAddresses);
    print('⭐ Set ${targetAddress.coinSymbol} ${targetAddress.network} address as default');
  }

  /// Get default address for coin+network
  CryptoAddressModel? getDefaultAddress(String coinSymbol, String network) {
    final List<CryptoAddressModel> addresses =
    getAddressesForCoinAndNetwork(coinSymbol, network);

    try {
      return addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      // No default found, return first if available
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  /// Clear all addresses (for testing)
  Future<void> clearAllAddresses() async {
    await _storage.remove(_addressesKey);
    print('🧹 Cleared all addresses');
  }
}

// Extension to add firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}