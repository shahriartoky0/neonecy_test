// lib/features/settings/controllers/change_address_controller.dart
import 'package:get/get.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/utils/address_storage_service.dart';
import '../../assets/model/coin_model.dart';
import '../model/crypto_address_model.dart';

class ChangeAddressController extends GetxController {
  final AddressStorageService _addressService = AddressStorageService();

  final RxList<CryptoAddressModel> addresses  = <CryptoAddressModel>[].obs;
  final RxList<String>             networks   = <String>[].obs; // ← reactive network list
  final RxString                   selectedCoinSymbol = ''.obs;
  final Rx<CoinItem?>              selectedCoin = Rx<CoinItem?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(selectedCoinSymbol, (String symbol) {
      if (symbol.isNotEmpty) {
        _reload(symbol);
        _reloadNetworks(symbol);
      } else {
        addresses.clear();
        networks.clear();
      }
    });
  }

  void selectCoin(CoinItem coin) {
    selectedCoin.value = coin;
    selectedCoinSymbol.value = coin.symbol;
  }

  void _reload(String symbol) =>
      addresses.value = _addressService.getAddressesForCoin(symbol);

  void _reloadNetworks(String symbol) =>
      networks.value = getAvailableNetworks(symbol);

  int addressCountForCoin(String symbol) =>
      _addressService.getAddressesForCoin(symbol).length;

  // ── Networks ───────────────────────────────────────────────────────────────
  //
  // Priority: storage > hardcoded defaults
  // Admin can add any custom string; defaults load the first time.

  /// Hardcoded defaults — used ONLY when no networks saved in storage yet.
  List<String> _defaultNetworks(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':   return ['SegWit', 'Bitcoin', 'BEP20'];
      case 'ETH':   return ['Ethereum', 'Arbitrum', 'Optimism', 'BEP20'];
      case 'USDT':  return ['TRC20', 'ERC20', 'BEP20', 'Polygon'];
      case 'BNB':   return ['BEP20', 'BEP2'];
      case 'USDC':  return ['ERC20', 'BEP20', 'Polygon'];
      case 'SOL':   return ['Solana', 'BEP20'];
      case 'XRP':   return ['Ripple', 'BEP20'];
      case 'ADA':   return ['Cardano', 'BEP20'];
      case 'DOGE':  return ['Dogecoin', 'BEP20'];
      case 'MATIC': return ['Polygon', 'BEP20', 'ERC20'];
      case 'TRX':   return ['TRC20', 'BEP20'];
      case 'TON':   return ['TON', 'BEP20'];
      case 'LTC':   return ['Litecoin', 'BEP20'];
      case 'AVAX':  return ['Avalanche C-Chain', 'BEP20'];
      case 'LINK':  return ['ERC20', 'BEP20'];
      case 'UNI':   return ['ERC20', 'BEP20'];
      case 'ATOM':  return ['Cosmos', 'BEP20'];
      case 'DOT':   return ['Polkadot', 'BEP20'];
      case 'SHIB':  return ['ERC20', 'BEP20'];
      default:      return ['ERC20', 'BEP20'];
    }
  }

  /// Returns networks for [symbol]: admin-saved first, else defaults.
  List<String> getAvailableNetworks(String symbol) {
    final saved = _addressService.getSavedNetworks(symbol);
    return saved.isNotEmpty ? saved : _defaultNetworks(symbol);
  }

  /// Admin adds a new network name for the current coin.
  Future<void> addNetwork(String networkName) async {
    final coin = selectedCoin.value;
    if (coin == null) return;
    final name = networkName.trim();
    if (name.isEmpty) return;

    // Ensure storage has the current list first (lazy-init defaults)
    final current = getAvailableNetworks(coin.symbol);
    if (current.contains(name)) {
      ToastManager.show(
        backgroundColor: AppColors.iconBackgroundLight,
        textColor: AppColors.white,
        message: '$name already exists',
      );
      return;
    }
    current.add(name);
    await _addressService.saveNetworks(coin.symbol, current);
    _reloadNetworks(coin.symbol);
    ToastManager.show(
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      message: '$name added',
    );
  }

  /// Admin removes a network (also deletes its saved address).
  Future<void> removeNetwork(String network) async {
    final coin = selectedCoin.value;
    if (coin == null) return;
    final current = getAvailableNetworks(coin.symbol);
    current.remove(network);
    await _addressService.saveNetworks(coin.symbol, current);
    await _addressService.deleteAddressForCoinNetwork(coin.symbol, network);
    _reloadNetworks(coin.symbol);
    _reload(coin.symbol);
    ToastManager.show(
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      message: '$network removed',
    );
  }

  /// Resets networks for current coin back to hardcoded defaults.
  Future<void> resetNetworksToDefaults() async {
    final coin = selectedCoin.value;
    if (coin == null) return;
    await _addressService.saveNetworks(coin.symbol, _defaultNetworks(coin.symbol));
    _reloadNetworks(coin.symbol);
    ToastManager.show(
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      message: 'Networks reset to defaults',
    );
  }

  // ── Address CRUD ──────────────────────────────────────────────────────────

  Future<void> addOrReplaceAddress({
    required String network,
    required String address,
    String? label,
  }) async {
    try {
      final coin = selectedCoin.value;
      if (coin == null) return;
      final existing =
      _addressService.getAddressesForCoinAndNetwork(coin.symbol, network);
      if (existing.isNotEmpty) {
        await _addressService.updateAddress(existing.first.copyWith(
          address: address.trim(),
          label: _cleanLabel(label),
        ));
        ToastManager.show(
          backgroundColor: AppColors.greenContainer,
          textColor: AppColors.white,
          message: '${coin.symbol} · $network address updated',
        );
      } else {
        await _addressService.addAddress(CryptoAddressModel.create(
          coinSymbol: coin.symbol,
          coinName: coin.name,
          network: network,
          address: address.trim(),
          label: _cleanLabel(label),
        ));
        ToastManager.show(
          backgroundColor: AppColors.greenContainer,
          textColor: AppColors.white,
          message: '${coin.symbol} · $network address saved',
        );
      }
      _reload(coin.symbol);
    } catch (e) {
      _err('Failed to save: $e');
    }
  }

  Future<void> updateAddress({
    required String addressId,
    required String network,
    required String address,
    String? label,
  }) async {
    try {
      final existing = addresses.firstWhere((a) => a.id == addressId);
      await _addressService.updateAddress(existing.copyWith(
        network: network,
        address: address.trim(),
        label: _cleanLabel(label),
      ));
      _reload(existing.coinSymbol);
      ToastManager.show(
        backgroundColor: AppColors.greenContainer,
        textColor: AppColors.white,
        message: 'Address updated',
      );
    } catch (e) {
      _err('Failed to update: $e');
    }
  }

  Future<void> removeAddress(String addressId) async {
    try {
      await _addressService.deleteAddress(addressId);
      _reload(selectedCoinSymbol.value);
      ToastManager.show(
        backgroundColor: AppColors.greenContainer,
        textColor: AppColors.white,
        message: 'Address removed',
      );
    } catch (e) {
      _err('Failed to remove: $e');
    }
  }

  // helpers
  String? _cleanLabel(String? l) =>
      l != null && l.trim().isNotEmpty ? l.trim() : null;

  void _err(String msg) => ToastManager.show(
    backgroundColor: AppColors.darkRed,
    textColor: AppColors.white,
    message: msg,
  );
}