// lib/features/assets/screens/withdraw/withdraw_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import 'package:neonecy_test/features/settings/model/crypto_address_model.dart';
import 'package:neonecy_test/features/wallet/models/coin_wallet_model.dart';

class WithdrawScreen extends StatefulWidget {
  final WalletCoinModel coin;

  const WithdrawScreen({super.key, required this.coin});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final AddressStorageService _addressService = AddressStorageService();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();

  List<CryptoAddressModel> _savedAddresses = <CryptoAddressModel>[];
  String _selectedNetwork = 'Automatically match the network';
  bool _isAutoNetwork = true;
  double _networkFee = 0.0;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _loadSavedAddresses() {
    final List<CryptoAddressModel> addresses = _addressService.getAddressesForCoin(widget.coin.coinDetails.symbol);
    setState(() => _savedAddresses = addresses);
    // Do NOT auto-fill address — user must choose where to send explicitly
    _calculateNetworkFee();
  }

  void _selectSavedAddress(CryptoAddressModel addr) {
    setState(() {
      _addressCtrl.text = addr.address;
      _selectedNetwork = addr.network;
      _isAutoNetwork = false;
    });
    _calculateNetworkFee();
  }

  void _calculateNetworkFee() {
    final String network = _isAutoNetwork ? 'TRC20' : _selectedNetwork;
    const Map<String, double> feeMap = <String, double>{
      'TRC20': 1.0,
      'ERC20': 5.0,
      'BEP20': 0.5,
      'Bitcoin': 0.0005,
      'SegWit': 0.0003,
      'Ethereum': 0.002,
      'Polygon': 0.1,
      'Solana': 0.00001,
      'Arbitrum': 0.5,
      'Optimism': 0.5,
      'Ripple': 0.25,
      'Cardano': 0.17,
      'Dogecoin': 5.0,
    };
    setState(() => _networkFee = feeMap[network] ?? 1.0);
  }

  void _validateAmount(String input) {
    final double amount = double.tryParse(input) ?? 0;
    final double available = widget.coin.quantity;
    setState(() {
      if (input.isEmpty) {
        _amountError = null;
      } else if (amount <= 0) {
        _amountError = 'Amount must be greater than 0';
      } else if (amount > available) {
        _amountError = 'Insufficient balance';
      } else if (amount < 0.001) {
        _amountError = 'Below minimum withdrawal (0.001)';
      } else {
        _amountError = null;
      }
    });
  }

  bool get _canWithdraw {
    final double amount = double.tryParse(_amountCtrl.text) ?? 0;
    return _addressCtrl.text.isNotEmpty &&
        amount > 0 &&
        amount <= widget.coin.quantity &&
        _amountError == null;
  }

  double get _receiveAmount {
    final double amount = double.tryParse(_amountCtrl.text) ?? 0;
    return amount > 0 ? (amount - _networkFee).clamp(0, double.infinity) : 0.0;
  }

  String _formatAddress(String addr) {
    if (addr.length <= 12) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 6)}';
  }

  List<String> _getAvailableNetworks() {
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

  @override
  Widget build(BuildContext context) {
    final String symbol = widget.coin.coinDetails.symbol;
    final double available = widget.coin.quantity;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: Column(
          children: <Widget>[
            Text(
              'Send $symbol',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('One Time', style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
                  Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textGreyLight),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.white),
            onPressed: () => _showNetworkInfo(),
          ),
        CustomSvgImage(assetName: AppIcons.assetHistory,height: 20,),
          const SizedBox(width: 8,)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Address ────────────────────────────────────────────────
            const Text('Address', style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: TextField(
                controller: _addressCtrl,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Long press to paste',
                  hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Contacts / saved addresses
                      if (_savedAddresses.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.account_circle_outlined,
                            color: AppColors.textGreyLight,
                            size: 22,
                          ),
                          onPressed: _showAddressSelector,
                          tooltip: 'Saved addresses',
                        ),
                      // QR scan
                      IconButton(
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.textGreyLight,
                          size: 22,
                        ),
                        onPressed: () {},
                        // onPressed: () => ToastManager.show(
                        //     message: 'QR Scanner coming soon'),
                        // tooltip: 'Scan QR',
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Network ─────────────────────────────────────────────────
            Row(
              children: <Widget>[
                const Text(
                  'Network',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _showNetworkInfo,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline, size: 12, color: AppColors.textGreyLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _showNetworkSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.iconBackground,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedNetwork,
                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textGreyLight, size: 22),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // ── Withdrawal Amount ────────────────────────────────────────
            Row(
              children: <Widget>[
                const Text(
                  'Withdrawal Amount',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: _showAmountInfo,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline, size: 12, color: AppColors.textGreyLight),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Amount field — pixel perfect match to screenshot
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                border: _amountError != null ? Border.all(color: AppColors.red, width: 1) : null,
              ),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Minimum 0',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                  ),
                  const Spacer(),
                  // Amount input
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _amountCtrl,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.textGreyLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _validateAmount,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    symbol,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Max button
                  GestureDetector(
                    onTap: () {
                      _amountCtrl.text = available.toString();
                      _validateAmount(_amountCtrl.text);
                    },
                    child: const Text(
                      'Max',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_amountError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _amountError!,
                  style: const TextStyle(color: AppColors.red, fontSize: 11),
                ),
              ),

            const SizedBox(height: 8),

            // Available
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Available',
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                ),
                Text(
                  '$available $symbol',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xxxL),

            // ── Warnings ─────────────────────────────────────────────────
            _WarningRow(
              text:
                  'Do not withdraw directly to a crowdfund or ICO. '
                  'We will not credit your account with tokens from that sale.',
            ),
            const SizedBox(height: AppSizes.sm),
            _WarningRow(
              text: 'Do not transact with Sanctioned Entities. ',
              linkText: 'Learn more',
              // onLinkTap: () => ToastManager.show(message: 'Learn more about sanctions'),
              onLinkTap: () {},
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // ── Sticky Bottom ────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
        decoration: const BoxDecoration(
          color: AppColors.bgColor,
          border: Border(top: BorderSide(color: AppColors.iconBackground, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Receive amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Receive amount',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                  ),
                  Text(
                    '${_receiveAmount.toStringAsFixed(8)} $symbol',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Network fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Network fee',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                  ),
                  Text(
                    '$_networkFee $symbol',
                    style: const TextStyle(color: AppColors.white, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              // Withdraw button — always yellow like Binance screenshot
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    disabledBackgroundColor: AppColors.yellow,
                    disabledForegroundColor: AppColors.black.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                  ),
                  onPressed: () {
                    DeviceUtility.hapticFeedback();
                    if (!_canWithdraw) {
                      // Show specific error toast instead of disabling
                      if (_addressCtrl.text.isEmpty) {
                        ToastManager.show(
                          message: 'Please enter a recipient address',
                          backgroundColor: AppColors.darkRed,
                          textColor: AppColors.white,
                        );
                      } else if (_amountCtrl.text.isEmpty ||
                          (double.tryParse(_amountCtrl.text) ?? 0) <= 0) {
                        ToastManager.show(
                          message: 'Please enter an amount',
                          backgroundColor: AppColors.darkRed,
                          textColor: AppColors.white,
                        );
                      } else if (_amountError != null) {
                        ToastManager.show(
                          message: _amountError!,
                          backgroundColor: AppColors.darkRed,
                          textColor: AppColors.white,
                        );
                      }
                      return;
                    }
                    _showWithdrawConfirmation();
                  },
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      ),
    );
  }

  // ── Address selector sheet ───────────────────────────────────────────────
  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
              'Select Address',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (_savedAddresses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Text(
                'No saved addresses for ${widget.coin.coinDetails.symbol}',
                style: const TextStyle(color: AppColors.textGreyLight),
                textAlign: TextAlign.center,
              ),
            )
          else
            ..._savedAddresses.map(
              (CryptoAddressModel addr) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.yellow,
                    size: 20,
                  ),
                ),
                title: Text(
                  addr.label ?? addr.network,
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _formatAddress(addr.address),
                      style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackgroundLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        addr.network,
                        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectSavedAddress(addr);
                },
              ),
            ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // ── Network selector sheet ───────────────────────────────────────────────
  void _showNetworkSelector() {
    final List<String> networks = _getAvailableNetworks();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
          // Auto option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.yellow, size: 18),
            ),
            title: const Text(
              'Automatically match the network',
              style: TextStyle(color: AppColors.white),
            ),
            trailing: _isAutoNetwork
                ? const Icon(Icons.check_circle, color: AppColors.yellow, size: 18)
                : null,
            onTap: () {
              setState(() {
                _isAutoNetwork = true;
                _selectedNetwork = 'Automatically match the network';
              });
              Navigator.pop(context);
              _calculateNetworkFee();
            },
          ),
          const Divider(color: AppColors.iconBackground, height: 1),
          ...networks.map((String net) {
            final bool isSelected = !_isAutoNetwork && _selectedNetwork == net;
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.iconBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  net,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                net,
                style: TextStyle(
                  color: isSelected ? AppColors.yellow : AppColors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.yellow, size: 18)
                  : null,
              onTap: () {
                setState(() {
                  _isAutoNetwork = false;
                  _selectedNetwork = net;
                });
                Navigator.pop(context);
                _calculateNetworkFee();
              },
            );
          }),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  // ── Confirm dialog ───────────────────────────────────────────────────────
  void _showWithdrawConfirmation() {
    final double amount = double.parse(_amountCtrl.text);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Confirm Withdrawal',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ConfirmRow(label: 'Coin', value: widget.coin.coinDetails.symbol),
            const SizedBox(height: 10),
            _ConfirmRow(label: 'Amount', value: '$amount ${widget.coin.coinDetails.symbol}'),
            const SizedBox(height: 10),
            _ConfirmRow(
              label: 'Network Fee',
              value: '$_networkFee ${widget.coin.coinDetails.symbol}',
            ),
            const SizedBox(height: 10),
            _ConfirmRow(
              label: 'You receive',
              value: '${_receiveAmount.toStringAsFixed(8)} ${widget.coin.coinDetails.symbol}',
              valueColor: AppColors.green,
            ),
            const Divider(color: AppColors.iconBackground, height: 24),
            _ConfirmRow(label: 'To', value: _formatAddress(_addressCtrl.text)),
            const SizedBox(height: 10),
            _ConfirmRow(label: 'Network', value: _selectedNetwork),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _executeWithdraw();
            },
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _executeWithdraw() {
    // TODO: connect to backend
    ToastManager.show(
      message: 'Withdrawal initiated successfully',
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      icon: const Icon(Icons.check_circle, color: AppColors.green),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      Get.back();
    });
  }

  void _showNetworkInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: const Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: AppColors.yellow, size: 20),
            SizedBox(width: 8),
            Text(
              'Network Info',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'The network must match the recipient platform\'s network. '
          'Sending on the wrong network may result in permanent loss of funds.',
          style: TextStyle(color: AppColors.textGreyLight, fontSize: 14, height: 1.4),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppColors.yellow)),
          ),
        ],
      ),
    );
  }

  void _showAmountInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: const Row(
          children: <Widget>[
            Icon(Icons.info_outline, color: AppColors.yellow, size: 20),
            SizedBox(width: 8),
            Text(
              'Withdrawal Amount',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Minimum: 0.001 ${widget.coin.coinDetails.symbol}',
              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Network fee: $_networkFee ${widget.coin.coinDetails.symbol}',
              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Receive = Amount − Network fee',
              style: TextStyle(color: AppColors.yellow, fontSize: 13),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppColors.yellow)),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────
class _WarningRow extends StatelessWidget {
  final String text;
  final String? linkText;
  final VoidCallback? onLinkTap;

  const _WarningRow({required this.text, this.linkText, this.onLinkTap});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Text('• ', style: TextStyle(color: AppColors.textGreyLight, fontSize: 12)),
      Expanded(
        child: RichText(
          text: TextSpan(
            text: text,
            style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.4),
            children: <InlineSpan>[
              if (linkText != null)
                WidgetSpan(
                  child: GestureDetector(
                    onTap: onLinkTap,
                    child: Text(
                      linkText!,
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ConfirmRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(label, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
      Flexible(
        child: Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
