class CryptoAddressModel {
  final String id;
  final String coinSymbol;
  final String coinName;
  final String network;
  final String address;
  final String? label;
  final DateTime createdAt;
  final bool isDefault;

  CryptoAddressModel({
    required this.id,
    required this.coinSymbol,
    required this.coinName,
    required this.network,
    required this.address,
    this.label,
    required this.createdAt,
    this.isDefault = false,
  });

  CryptoAddressModel copyWith({
    String? id,
    String? coinSymbol,
    String? coinName,
    String? network,
    String? address,
    String? label,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return CryptoAddressModel(
      id: id ?? this.id,
      coinSymbol: coinSymbol ?? this.coinSymbol,
      coinName: coinName ?? this.coinName,
      network: network ?? this.network,
      address: address ?? this.address,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coinSymbol': coinSymbol,
      'coinName': coinName,
      'network': network,
      'address': address,
      'label': label,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory CryptoAddressModel.fromJson(Map<String, dynamic> json) {
    return CryptoAddressModel(
      id: json['id'],
      coinSymbol: json['coinSymbol'],
      coinName: json['coinName'],
      network: json['network'],
      address: json['address'],
      label: json['label'],
      createdAt: DateTime.parse(json['createdAt']),
      isDefault: json['isDefault'] ?? false,
    );
  }
}

// Demo Data Generator
class CryptoAddressModelDemo {
  // Generate realistic-looking addresses based on blockchain type
  static String _generateBitcoinAddress() {
    const chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final random = DateTime.now().millisecondsSinceEpoch;
    String address = '1';
    for (int i = 0; i < 33; i++) {
      address += chars[(random + i) % chars.length];
    }
    return address;
  }

  static String _generateEthereumAddress() {
    const chars = '0123456789abcdef';
    final random = DateTime.now().millisecondsSinceEpoch;
    String address = '0x';
    for (int i = 0; i < 40; i++) {
      address += chars[(random + i) % chars.length];
    }
    return address;
  }

  static String _generateTronAddress() {
    const chars = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    final random = DateTime.now().millisecondsSinceEpoch;
    String address = 'T';
    for (int i = 0; i < 33; i++) {
      address += chars[(random + i) % chars.length];
    }
    return address;
  }

  static List<CryptoAddressModel> getDemoAddresses() {
    return [
      CryptoAddressModel(
        id: '1',
        coinSymbol: 'APTOS',
        coinName: 'Aptos',
        network: 'Aptos',
        address: '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        label: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isDefault: true,
      ),
      CryptoAddressModel(
        id: '2',
        coinSymbol: 'BNB',
        coinName: 'BNB Smart Chain',
        network: 'BEP20',
        address: _generateEthereumAddress(),
        label: 'BNB SMART CHAIN (BEP20)',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        isDefault: false,
      ),
      CryptoAddressModel(
        id: '3',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        network: 'Ethereum',
        address: _generateEthereumAddress(),
        label: null,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        isDefault: false,
      ),
      CryptoAddressModel(
        id: '4',
        coinSymbol: 'ETH',
        coinName: 'Ethereum',
        network: 'Ethereum',
        address: _generateEthereumAddress(),
        label: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isDefault: false,
      ),
      CryptoAddressModel(
        id: '5',
        coinSymbol: 'BNB',
        coinName: 'BNB Smart Chain',
        network: 'BEP20',
        address: _generateEthereumAddress(),
        label: 'BNB SMART CHAIN (BEP20)',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        isDefault: false,
      ),
      CryptoAddressModel(
        id: '6',
        coinSymbol: 'BNB',
        coinName: 'BNB Smart Chain',
        network: 'BEP20',
        address: _generateEthereumAddress(),
        label: 'BNB SMART CHAIN (BEP20)',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isDefault: false,
      ),
      CryptoAddressModel(
        id: '7',
        coinSymbol: 'BNB',
        coinName: 'BNB Smart Chain',
        network: 'BEP20',
        address: _generateEthereumAddress(),
        label: 'BNB SMART CHAIN (BEP20)',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isDefault: false,
      ),
    ];
  }

  // Get addresses for specific coin
  static List<CryptoAddressModel> getAddressesForCoin(String coinSymbol) {
    return getDemoAddresses().where((address) => address.coinSymbol == coinSymbol).toList();
  }

  // Generate new address for a coin
  static CryptoAddressModel generateNewAddress(String coinSymbol, String coinName, String network) {
    String address;

    switch (network.toUpperCase()) {
      case 'BITCOIN':
      case 'BTC':
        address = _generateBitcoinAddress();
        break;
      case 'ETHEREUM':
      case 'ETH':
      case 'BEP20':
      case 'ERC20':
        address = _generateEthereumAddress();
        break;
      case 'TRON':
      case 'TRC20':
        address = _generateTronAddress();
        break;
      default:
        address = _generateEthereumAddress();
    }

    return CryptoAddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coinSymbol: coinSymbol,
      coinName: coinName,
      network: network,
      address: address,
      label: null,
      createdAt: DateTime.now(),
      isDefault: false,
    );
  }
}
