import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import '../../assets/model/coin_model.dart';
import '../model/crypto_address_model.dart';

class ChangeAddressController extends GetxController {
  final RxList<CryptoAddressModel> addresses = <CryptoAddressModel>[].obs;
  final RxList<CryptoAddressModel> filteredAddresses = <CryptoAddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<CryptoAddressModel?> selectedAddress = Rx<CryptoAddressModel?>(null);

  // The coin we're managing addresses for
  late CoinItem coin;

  @override
  void onInit() {
    super.onInit();
    // Get the coin passed from previous screen
    if (Get.arguments != null && Get.arguments is CoinItem) {
      coin = Get.arguments as CoinItem;
      loadAddresses();
    }
  }

  void loadAddresses() {
    isLoading.value = true;

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Load demo addresses for this coin
      addresses.value = CryptoAddressModelDemo.getAddressesForCoin(coin.symbol);

      // If no addresses exist, generate some
      if (addresses.isEmpty) {
        addresses.value = _generateDemoAddressesForCoin();
      }

      filteredAddresses.value = addresses;

      // Set default selected address
      final CryptoAddressModel defaultAddress = addresses.firstWhere(
        (CryptoAddressModel addr) => addr.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : _createNewAddress(),
      );
      selectedAddress.value = defaultAddress;

      isLoading.value = false;
    });
  }

  List<CryptoAddressModel> _generateDemoAddressesForCoin() {
    // Generate 3-5 demo addresses for the coin
    final List<CryptoAddressModel> demoAddresses = <CryptoAddressModel>[];
    final int count = 3 + (coin.symbol.hashCode % 3); // 3-5 addresses

    for (int i = 0; i < count; i++) {
      final CryptoAddressModel address = CryptoAddressModelDemo.generateNewAddress(
        coin.symbol,
        coin.name,
        _getNetworkForCoin(coin.symbol),
      );
      demoAddresses.add(address.copyWith(id: '${coin.symbol}_$i', isDefault: i == 0));
    }

    return demoAddresses;
  }

  String _getNetworkForCoin(String symbol) {
    // Map common coins to their networks
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum';
      case 'BNB':
        return 'BEP20';
      case 'USDT':
      case 'USDC':
        return 'ERC20';
      case 'TRX':
        return 'TRON';
      case 'SOL':
        return 'Solana';
      case 'ADA':
        return 'Cardano';
      case 'DOT':
        return 'Polkadot';
      case 'MATIC':
        return 'Polygon';
      case 'AVAX':
        return 'Avalanche';
      default:
        return 'Ethereum'; // Default to Ethereum
    }
  }

  CryptoAddressModel _createNewAddress() {
    return CryptoAddressModelDemo.generateNewAddress(
      coin.symbol,
      coin.name,
      _getNetworkForCoin(coin.symbol),
    );
  }

  void searchAddresses(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredAddresses.value = addresses;
    } else {
      filteredAddresses.value = addresses.where((CryptoAddressModel address) {
        return address.address.toLowerCase().contains(query.toLowerCase()) ||
            address.network.toLowerCase().contains(query.toLowerCase()) ||
            (address.label?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredAddresses.value = addresses;
  }

  void selectAddress(CryptoAddressModel address) {
    selectedAddress.value = address;
    // You can add logic here to save the selection
    // Get.back(result: address);
  }

  void addNewAddress() {
    final CryptoAddressModel newAddress = _createNewAddress();
    addresses.insert(0, newAddress);
    filteredAddresses.value = addresses;

    ToastManager.show(message: "New address generated");
  }

  void deleteAddress(CryptoAddressModel address) {
    if (address.isDefault) {
      Get.snackbar('Error', 'Cannot delete default address', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    addresses.remove(address);
    filteredAddresses.value = addresses;
    ToastManager.show(message: "Address deleted");
  }

  void setAsDefault(CryptoAddressModel address) {
    // Remove default from all addresses
    for (CryptoAddressModel addr in addresses) {
      if (addr.id == address.id) {
        final int index = addresses.indexOf(addr);
        addresses[index] = addr.copyWith(isDefault: true);
      } else if (addr.isDefault) {
        final int index = addresses.indexOf(addr);
        addresses[index] = addr.copyWith(isDefault: false);
      }
    }

    filteredAddresses.value = addresses;
    selectedAddress.value = address;
    ToastManager.show(message: "Default address updated");
  }
}
