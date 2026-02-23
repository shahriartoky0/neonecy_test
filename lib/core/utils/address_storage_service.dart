// lib/core/utils/address_storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../../features/settings/model/crypto_address_model.dart';

class AddressStorageService {
  static const String _addressesKey       = 'crypto_addresses';
  static const String _networksKey        = 'coin_networks';   // ← NEW
  static const String _depositHistoryKey  = 'deposit_history';
  static const String _withdrawHistoryKey = 'withdraw_history';

  final GetStorage _storage = GetStorage();

  // ══════════════════════════════════════════════════════════════════════════
  // COIN NETWORKS  (admin-configurable)
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns networks the admin saved for [coinSymbol].
  /// Empty list means "not configured yet — use defaults".
  List<String> getSavedNetworks(String coinSymbol) {
    final dynamic raw = _storage.read(_networksKey);
    if (raw == null) return [];
    final map = Map<String, dynamic>.from(raw as Map);
    final list = map[coinSymbol.toUpperCase()];
    if (list == null) return [];
    return List<String>.from(list as List);
  }

  /// Overwrites the network list for [coinSymbol].
  Future<void> saveNetworks(String coinSymbol, List<String> networks) async {
    final dynamic raw = _storage.read(_networksKey);
    final map = raw != null ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};
    if (networks.isEmpty) {
      map.remove(coinSymbol.toUpperCase());
    } else {
      map[coinSymbol.toUpperCase()] = networks;
    }
    await _storage.write(_networksKey, map);
    print('🌐 Saved ${networks.length} networks for $coinSymbol: $networks');
  }

  /// Adds a single network to [coinSymbol] if not already present.
  Future<void> addNetwork(String coinSymbol, String network) async {
    final networks = getSavedNetworks(coinSymbol);
    if (!networks.contains(network)) {
      networks.add(network);
      await saveNetworks(coinSymbol, networks);
    }
  }

  /// Removes a single network from [coinSymbol].
  /// Also deletes any address saved for that coin+network.
  Future<void> removeNetwork(String coinSymbol, String network) async {
    final networks = getSavedNetworks(coinSymbol);
    networks.remove(network);
    await saveNetworks(coinSymbol, networks);
    // Also clean up address for this network
    await deleteAddressForCoinNetwork(coinSymbol, network);
  }

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
  }

  void clearDepositHistory() => _storage.write(_depositHistoryKey, <String>[]);

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
  }

  void clearWithdrawHistory() => _storage.write(_withdrawHistoryKey, <String>[]);

  // ══════════════════════════════════════════════════════════════════════════
  // ADDRESS CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> saveAddresses(List<CryptoAddressModel> addresses) async {
    await _storage.write(
      _addressesKey,
      addresses.map((a) => a.toJson()).toList(),
    );
  }

  List<CryptoAddressModel> loadAddresses() {
    final dynamic data = _storage.read(_addressesKey);
    if (data == null) return [];
    try {
      return (data as List)
          .map((j) => CryptoAddressModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading addresses: $e');
      return [];
    }
  }

  List<CryptoAddressModel> getAddressesForCoin(String coinSymbol) =>
      loadAddresses()
          .where((a) =>
      a.coinSymbol.toUpperCase() == coinSymbol.toUpperCase())
          .toList();

  List<CryptoAddressModel> getAddressesForCoinAndNetwork(
      String coinSymbol, String network) =>
      getAddressesForCoin(coinSymbol)
          .where((a) => a.network.toUpperCase() == network.toUpperCase())
          .toList();

  Future<void> addAddress(CryptoAddressModel newAddress) async {
    final all = loadAddresses();
    all.add(newAddress.copyWith(isDefault: true));
    await saveAddresses(all);
  }

  Future<void> updateAddress(CryptoAddressModel updated) async {
    final all = loadAddresses();
    final i = all.indexWhere((a) => a.id == updated.id);
    if (i != -1) {
      all[i] = updated;
      await saveAddresses(all);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final all = loadAddresses()..removeWhere((a) => a.id == addressId);
    await saveAddresses(all);
  }

  /// Deletes the address for a specific coin+network (used when removing a network).
  Future<void> deleteAddressForCoinNetwork(
      String coinSymbol, String network) async {
    final all = loadAddresses()
      ..removeWhere((a) =>
      a.coinSymbol.toUpperCase() == coinSymbol.toUpperCase() &&
          a.network.toUpperCase() == network.toUpperCase());
    await saveAddresses(all);
  }

  CryptoAddressModel? getDefaultAddress(String coinSymbol, String network) {
    final list = getAddressesForCoinAndNetwork(coinSymbol, network);
    try { return list.firstWhere((a) => a.isDefault); }
    catch (_) { return list.isNotEmpty ? list.first : null; }
  }

  Future<void> clearAllAddresses() async => _storage.remove(_addressesKey);
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) { if (test(e)) return e; }
    return null;
  }
}