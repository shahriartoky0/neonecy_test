// lib/features/assets/screens/add_new_address_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';
import 'package:neonecy_test/features/settings/model/crypto_address_model.dart';
import 'package:neonecy_test/features/wallet/models/coin_wallet_model.dart';

class AddNewAddressScreen extends StatefulWidget {
  final WalletCoinModel coin;

  const AddNewAddressScreen({super.key, required this.coin});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final AddressStorageService _addressService = AddressStorageService();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _labelCtrl = TextEditingController();

  bool _isUniversal = false;
  String? _selectedNetwork;
  String? _selectedPlatform;

  static const List<String> _platforms = <String>[
    'Binance',
    'Coinbase',
    'Kraken',
    'OKX',
    'Bybit',
    'KuCoin',
    'Huobi',
    'Gate.io',
    'MetaMask',
    'Trust Wallet',
    'Ledger',
    'Other',
  ];

  List<String> get _networks {
    switch (widget.coin.coinDetails.symbol.toUpperCase()) {
      case 'BTC':
        return <String>['Bitcoin', 'SegWit', 'BEP20'];
      case 'ETH':
        return <String>['Ethereum', 'Arbitrum', 'Optimism', 'BEP20'];
      case 'USDT':
      case 'USDC':
        return <String>['TRC20', 'ERC20', 'BEP20', 'Polygon'];
      case 'BNB':
        return <String>['BEP20', 'BEP2'];
      case 'SOL':
        return <String>['Solana', 'BEP20'];
      case 'XRP':
        return <String>['Ripple', 'BEP20'];
      case 'ADA':
        return <String>['Cardano', 'BEP20'];
      case 'DOGE':
        return <String>['Dogecoin', 'BEP20'];
      case 'MATIC':
        return <String>['Polygon', 'ERC20', 'BEP20'];
      default:
        return <String>['ERC20', 'BEP20'];
    }
  }

  bool get _canSave => _addressCtrl.text.trim().isNotEmpty && _selectedNetwork != null;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String symbol = widget.coin.coinDetails.symbol;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Add New Address',
              style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Coin ──────────────────────────────────────────────────────
            const Text('Coin', style: TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.iconBackgroundLight,
                    backgroundImage: widget.coin.coinDetails.thumb.isNotEmpty
                        ? NetworkImage(widget.coin.coinDetails.thumb)
                        : null,
                    child: widget.coin.coinDetails.thumb.isEmpty
                        ? Text(
                            symbol[0],
                            style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    symbol,
                    style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.textGreyLight, size: 20),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // ── Universal address checkbox ─────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _isUniversal = !_isUniversal),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _isUniversal,
                      onChanged: (bool? v) => setState(() => _isUniversal = v ?? false),
                      activeColor: AppColors.yellow,
                      checkColor: AppColors.black,
                      side: const BorderSide(color: AppColors.textGreyLight, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          const TextSpan(
                            text: 'Set as a universal address, without specific coins. Choose this option for Alpha tokens. ',
                            style: TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.5),
                          ),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'View More',
                                style: TextStyle(color: AppColors.yellow, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Address ───────────────────────────────────────────────────
            const Text('Address', style: TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
            const SizedBox(height: AppSizes.sm),
            GestureDetector(
              onLongPress: () async {
                final ClipboardData? data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  _addressCtrl.text = data!.text!.trim();
                  setState(() {});
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.iconBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
                child: TextField(
                  controller: _addressCtrl,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Long press to paste',
                    hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.crop_free, color: AppColors.textGreyLight, size: 20),
                      onPressed: () {},
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Select Network ────────────────────────────────────────────
            const Text('Select Network', style: TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedNetwork,
                  isExpanded: true,
                  dropdownColor: AppColors.iconBackground,
                  iconEnabledColor: AppColors.textGreyLight,
                  hint: const Text('Select Network', style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  items: _networks
                      .map(
                        (String n) => DropdownMenuItem<String>(
                          value: n,
                          child: Text(n, style: const TextStyle(color: AppColors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (String? v) => setState(() => _selectedNetwork = v),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Address Origin ────────────────────────────────────────────
            const Text('Address Origin', style: TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPlatform,
                  isExpanded: true,
                  dropdownColor: AppColors.iconBackground,
                  iconEnabledColor: AppColors.textGreyLight,
                  hint: const Text('Select Platform', style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  items: _platforms
                      .map(
                        (String p) => DropdownMenuItem<String>(
                          value: p,
                          child: Text(p, style: const TextStyle(color: AppColors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (String? v) => setState(() => _selectedPlatform = v),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Wallet Label ──────────────────────────────────────────────
            const Text('Wallet Label (Optional)', style: TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
            const SizedBox(height: AppSizes.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: TextField(
                controller: _labelCtrl,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Enter wallet label',
                  hintStyle: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xxxL),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow.withValues(alpha: _canSave ? 1.0 : 0.4),
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                ),
                onPressed: _canSave ? _save : null,
                child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final String address = _addressCtrl.text.trim();
    final String network = _selectedNetwork!;
    final String? label = _labelCtrl.text.trim().isNotEmpty ? _labelCtrl.text.trim() : null;

    final CryptoAddressModel newAddress = CryptoAddressModel.create(
      coinSymbol: widget.coin.coinDetails.symbol,
      coinName: widget.coin.coinDetails.name,
      network: network,
      address: address,
      label: label,
    );

    await _addressService.addAddress(newAddress);

    ToastManager.show(
      message: 'Address saved successfully',
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      icon: const Icon(Icons.check_circle, color: AppColors.green),
    );

    if (mounted) Get.back();
  }
}
