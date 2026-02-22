// lib/features/settings/controllers/change_address_controller.dart
import 'package:get/get.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import '../../../core/common/widgets/custom_toast.dart';
import '../../../core/utils/address_storage_service.dart';
import '../../assets/model/coin_model.dart';
import '../model/crypto_address_model.dart';

class ChangeAddressController extends GetxController {
  final AddressStorageService _addressService = AddressStorageService();

  final RxList<CryptoAddressModel> addresses = <CryptoAddressModel>[].obs;
  final RxString selectedCoinSymbol = ''.obs;
  final Rx<CoinItem?> selectedCoin = Rx<CoinItem?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(selectedCoinSymbol, (String symbol) {
      if (symbol.isNotEmpty) {
        _reload(symbol);
      } else {
        addresses.clear();
      }
    });
  }

  void selectCoin(CoinItem coin) {
    selectedCoin.value = coin;
    selectedCoinSymbol.value = coin.symbol;
  }

  void _reload(String symbol) {
    addresses.value = _addressService.getAddressesForCoin(symbol);
  }

  int addressCountForCoin(String symbol) =>
      _addressService.getAddressesForCoin(symbol).length;

  // ── Add OR replace (one address per coin+network, no "default" concept) ──
  //
  // Rule: each coin+network pair holds exactly ONE address.
  // If the admin adds a second address for the same coin+network,
  // it silently replaces the old one instead of duplicating.
  Future<void> addOrReplaceAddress({
    required String network,
    required String address,
    String? label,
  }) async {
    try {
      final coin = selectedCoin.value;
      if (coin == null) return;

      final existing = _addressService
          .getAddressesForCoinAndNetwork(coin.symbol, network);

      if (existing.isNotEmpty) {
        // Replace — update the existing record in place
        final updated = existing.first.copyWith(
          address: address.trim(),
          label: label?.trim().isNotEmpty == true ? label!.trim() : null,
        );
        await _addressService.updateAddress(updated);
        ToastManager.show(
          backgroundColor: AppColors.greenContainer,
          textColor: AppColors.white,
          message: '${coin.symbol} · $network address updated',
        );
      } else {
        // First address for this coin+network — just add it
        final newAddr = CryptoAddressModel.create(
          coinSymbol: coin.symbol,
          coinName: coin.name,
          network: network,
          address: address.trim(),
          label: label?.trim().isNotEmpty == true ? label!.trim() : null,
        );
        await _addressService.addAddress(newAddr);
        ToastManager.show(
          backgroundColor: AppColors.greenContainer,
          textColor: AppColors.white,
          message: '${coin.symbol} · $network address saved',
        );
      }

      _reload(coin.symbol);
    } catch (e) {
      ToastManager.show(
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
        message: 'Failed to save: $e',
      );
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
        label: label?.trim().isNotEmpty == true ? label!.trim() : null,
      ));
      _reload(existing.coinSymbol);
      ToastManager.show(
        backgroundColor: AppColors.greenContainer,
        textColor: AppColors.white,
        message: 'Address updated',
      );
    } catch (e) {
      ToastManager.show(
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
        message: 'Failed to update: $e',
      );
    }
  }

  Future<void> removeAddress(String addressId) async {
    try {
      // await _addressService.removeAddress(addressId);
      _reload(selectedCoinSymbol.value);
      ToastManager.show(
        backgroundColor: AppColors.greenContainer,
        textColor: AppColors.white,
        message: 'Address removed',
      );
    } catch (e) {
      ToastManager.show(
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
        message: 'Failed to remove: $e',
      );
    }
  }

  List<String> getAvailableNetworks(String symbol) {
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
}