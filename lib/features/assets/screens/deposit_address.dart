// lib/features/assets/screens/deposit/deposit_address_screen.dart
//
// pubspec.yaml:  qr_flutter: ^4.1.0
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';
import 'package:neonecy_test/features/assets/model/coin_model.dart';
import 'package:neonecy_test/features/settings/model/crypto_address_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DepositAddressScreen extends StatefulWidget {
  final CoinItem coin;

  const DepositAddressScreen({super.key, required this.coin});

  @override
  State<DepositAddressScreen> createState() => _DepositAddressScreenState();
}

class _DepositAddressScreenState extends State<DepositAddressScreen> {
  final AddressStorageService _addressService = AddressStorageService();
  late List<String> _networks;
  String? _selectedNetwork;
  CryptoAddressModel? _currentAddress;
  bool _detailsExpanded = false;

  @override
  void initState() {
    super.initState();
    _initNetworks();
  }

  void _initNetworks() {
    final saved = _addressService
        .getAddressesForCoin(widget.coin.symbol)
        .map((a) => a.network)
        .toSet()
        .toList();
    final defaults = _defaultNetworksFor(widget.coin.symbol);
    final merged = {...saved, ...defaults}.toList();
    _networks = merged;
    _selectedNetwork = merged.isNotEmpty ? merged.first : null;
    if (_selectedNetwork != null) _loadAddress(_selectedNetwork!);
  }

  void _loadAddress(String network) {
    setState(() {
      _selectedNetwork = network;
      _currentAddress = _addressService.getDefaultAddress(widget.coin.symbol, network);
    });
  }

  List<String> _defaultNetworksFor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return ['SegWit', 'Bitcoin', 'BEP20'];
      case 'ETH':
        return ['Ethereum', 'Arbitrum', 'Optimism', 'BEP20'];
      case 'USDT':
        return ['TRC20', 'ERC20', 'BEP20', 'Polygon'];
      case 'BNB':
        return ['BEP20', 'BEP2'];
      case 'USDC':
        return ['ERC20', 'BEP20', 'Polygon'];
      case 'SOL':
        return ['Solana', 'BEP20'];
      default:
        return ['ERC20', 'BEP20'];
    }
  }

  String _networkLabel(String network) {
    const map = {
      'SegWit': 'SEGWITBTC',
      'Bitcoin': 'BTC',
      'Ethereum': 'ETH',
      'TRC20': 'TRC20',
      'ERC20': 'ERC20',
      'BEP20': 'BSC',
      'BEP2': 'BEP2',
      'Polygon': 'MATIC',
      'Arbitrum': 'ARB',
      'Optimism': 'OP',
      'Solana': 'SOL',
    };
    return map[network] ?? network.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.white,
        title: Text(
          'Deposit ${widget.coin.symbol}',
          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.white),
            onPressed: () => _showDepositTips(context),
          ),
          CustomSvgImage(assetName: AppIcons.assetHistory, color: AppColors.white, height: 20),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.lg),

            // ── QR ────────────────────────────────────────────────────────
            Center(
              child: _currentAddress != null
                  ? _RealQr(address: _currentAddress!.address, coinThumb: widget.coin.thumb)
                  : _EmptyQr(onTap: () => _showNetworkSheet(context)),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Network ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Network',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _showNetworkSheet(context),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedNetwork != null
                                    ? _networkLabel(_selectedNetwork!)
                                    : 'Please choose network first',
                                style: TextStyle(
                                  color: _selectedNetwork != null
                                      ? AppColors.white
                                      : AppColors.textGreyLight,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedNetwork != null)
                                Text(
                                  _selectedNetwork!,
                                  style: const TextStyle(
                                    color: AppColors.textGreyLight,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.iconBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.swap_horiz, color: AppColors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),
            const Divider(color: AppColors.iconBackground, height: 1),
            const SizedBox(height: AppSizes.md),

            // ── Address ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: _currentAddress == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deposit Address',
                          style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Please choose network first',
                          style: TextStyle(
                            color: AppColors.textGreyLight.withOpacity(0.6),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deposit Address',
                          style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: _highlightAddress(_currentAddress!.address),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _copy(_currentAddress!.address),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.iconBackground,
                                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                                ),
                                child: const Icon(
                                  Icons.content_copy,
                                  color: AppColors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          '${widget.coin.name} supports deposits from all '
                          '${widget.coin.symbol} addresses on the '
                          '${_selectedNetwork ?? ""} network only.',
                          style: const TextStyle(color: AppColors.red, fontSize: 11),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: AppSizes.md),
            const Divider(color: AppColors.iconBackground, height: 1),

            // ── More Details ──────────────────────────────────────────────
            if (_currentAddress != null) ...[
              GestureDetector(
                onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'More Details',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _detailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textGreyLight,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              if (_detailsExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    // decoration: BoxDecoration(
                    //   color: AppColors.iconBackground,
                    //   borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    // ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Deposit to',
                          value: _currentAddress!.label ?? 'Spot Wallet',
                        ),
                        const Divider(color: AppColors.iconBackgroundLight, height: 16),
                        _DetailRow(label: 'Minimum deposit', value: ">0.0001 ${_currentAddress!.network}"),
                        const Divider(color: AppColors.iconBackgroundLight, height: 16),
                        _DetailRow(
                          label: 'Credited (Trading enabled)',
                          value: _currentAddress!.isDefault
                              ? '2 Confirmation(s)'
                              : '1 Confirmation(s)',
                        ),
                        const Divider(color: AppColors.iconBackgroundLight, height: 16),
                        _DetailRow(
                          label: 'Unlocked (Withdrawal enabled)',
                          value: _currentAddress!.isDefault
                              ? '2 Confirmation(s)'
                              : '1 Confirmation(s)',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── Bottom button ─────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.md),
          child: _currentAddress != null
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _copy(_currentAddress!.address),
                  child: const Text('Save and Share Address', style: TextStyle(fontSize: 16)),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iconBackground,
                    foregroundColor: AppColors.textGreyLight,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  // onPressed: () => ToastManager.show(
                  //   backgroundColor: AppColors.iconBackground,
                  //   textColor: AppColors.white,
                  //   message:
                  //       'Go to Settings → Crypto Addresses to add a '
                  //       '${widget.coin.symbol} address first',
                  // ),
                  child: const Text('No Address Found', style: TextStyle(fontSize: 15)),
                ),
        ),
      ),
    );
  }

  List<TextSpan> _highlightAddress(String addr) {
    if (addr.length <= 10) {
      return [
        TextSpan(
          text: addr,
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ];
    }
    return [
      TextSpan(
        text: addr.substring(0, 4),
        style: const TextStyle(
          color: AppColors.yellow,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ),
      TextSpan(
        text: addr.substring(4, addr.length - 4),
        style: const TextStyle(color: AppColors.white, fontSize: 15, height: 1.6),
      ),
      TextSpan(
        text: addr.substring(addr.length - 4),
        style: const TextStyle(
          color: AppColors.yellow,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ),
    ];
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ToastManager.show(
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      message: 'Address copied to clipboard',
      icon: const Icon(Icons.check_circle, color: AppColors.green),
    );
  }

  void _showNetworkSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSizes.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.iconBackgroundLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSizes.md),
            child: Text(
              'Select Network',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ..._networks.map((net) {
            final hasAddr = _addressService
                .getAddressesForCoinAndNetwork(widget.coin.symbol, net)
                .isNotEmpty;
            final isSelected = net == _selectedNetwork;
            return ListTile(
              leading: Container(
                width: 44,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _networkLabel(net),
                  style: TextStyle(
                    color: isSelected ? AppColors.yellow : AppColors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              title: Text(
                net,
                style: TextStyle(
                  color: isSelected ? AppColors.yellow : AppColors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                hasAddr ? 'Address saved' : 'No address saved',
                style: TextStyle(
                  color: hasAddr ? AppColors.green : AppColors.textGreyLight,
                  fontSize: 11,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.yellow, size: 18)
                  : hasAddr
                  ? const Icon(Icons.check_circle_outline, color: AppColors.green, size: 18)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _loadAddress(net);
              },
            );
          }),
          const SizedBox(height: AppSizes.xxxL),
        ],
      ),
    );
  }

  void _showDepositTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.yellow, size: 20),
            SizedBox(width: 8),
            Text(
              'Deposit Tips',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TipRow(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.yellow,
              text: 'Only send ${widget.coin.symbol} to this deposit address.',
            ),
            const SizedBox(height: AppSizes.sm),
            const _TipRow(
              icon: Icons.swap_horiz,
              iconColor: AppColors.white,
              text: "Ensure the selected network matches the sender's network.",
            ),
            const SizedBox(height: AppSizes.sm),
            const _TipRow(
              icon: Icons.close_rounded,
              iconColor: AppColors.red,
              text:
                  'Sending coins on an incompatible network may result in permanent loss of funds.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real scannable QR using qr_flutter
// ─────────────────────────────────────────────────────────────────────────────
class _RealQr extends StatelessWidget {
  final String address;
  final String coinThumb;

  const _RealQr({required this.address, required this.coinThumb});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: address,
        // real wallet address
        version: QrVersions.auto,
        size: 180,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
        embeddedImage: coinThumb.isNotEmpty ? NetworkImage(coinThumb) : null,
        embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(36, 36)),
        errorCorrectionLevel: QrErrorCorrectLevel.H, // required for embedded image
      ),
    );
  }
}

class _EmptyQr extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyQr({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          border: Border.all(color: AppColors.iconBackgroundLight, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 64, color: AppColors.textGreyLight),
            const SizedBox(height: 8),
            const Text(
              'No address saved\nfor this network',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.iconBackgroundLight,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              ),
              child: const Text(
                'Change network',
                style: TextStyle(color: AppColors.yellow, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _TipRow({required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: iconColor, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13, height: 1.4),
        ),
      ),
    ],
  );
}
