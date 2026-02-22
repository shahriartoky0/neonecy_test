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
      id: json['id'] as String,
      coinSymbol: json['coinSymbol'] as String,
      coinName: json['coinName'] as String,
      network: json['network'] as String,
      address: json['address'] as String,
      label: json['label'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  // Factory method to create new address
  factory CryptoAddressModel.create({
    required String coinSymbol,
    required String coinName,
    required String network,
    required String address,
    String? label,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return CryptoAddressModel(
      id: '${coinSymbol}_${network}_${timestamp}',
      coinSymbol: coinSymbol,
      coinName: coinName,
      network: network,
      address: address.trim(),
      label: label?.trim().isNotEmpty == true ? label!.trim() : null,
      createdAt: DateTime.now(),
      isDefault: false,
    );
  }
}