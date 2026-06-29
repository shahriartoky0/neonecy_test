// lib/features/assets/screens/withdraw.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import 'package:neonecy_test/features/assets/screens/add_new_address_screen.dart';
import 'package:neonecy_test/features/settings/model/crypto_address_model.dart';
import 'package:neonecy_test/features/wallet/controllers/wallet_controller.dart';
import 'package:neonecy_test/features/wallet/models/coin_wallet_model.dart';

import '../widgets/network_sheet_content.dart';

class WithdrawScreen extends StatefulWidget {
  final WalletCoinModel coin;

  const WithdrawScreen({super.key, required this.coin});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final AddressStorageService _addressService = AddressStorageService();
  final WalletController _walletController = Get.find<WalletController>();
  final TextEditingController _amountCtrl = TextEditingController();

  String _address = '';
  List<CryptoAddressModel> _savedAddresses = <CryptoAddressModel>[];
  String _selectedNetwork = 'Select Network';
  bool _isAutoNetwork = true;
  double _networkFee = 0.0;
  String? _amountError;
  bool _isProcessing = false;
  bool _cautionExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _loadSavedAddresses() {
    final List<CryptoAddressModel> addresses = _addressService.getAddressesForCoin(
      widget.coin.coinDetails.symbol,
    );
    setState(() => _savedAddresses = addresses);
    _calculateNetworkFee();
  }

  void _selectSavedAddress(CryptoAddressModel addr) {
    setState(() {
      _address = addr.address;
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
    return !_isProcessing &&
        _address.isNotEmpty &&
        amount > 0 &&
        amount <= widget.coin.quantity &&
        _amountError == null;
  }

  double get _receiveAmount {
    final double amount = double.tryParse(_amountCtrl.text) ?? 0;
    return amount > 0 ? (amount - _networkFee).clamp(0, double.infinity) : 0.0;
  }

  double get _fiatValue {
    final double amount = double.tryParse(_amountCtrl.text) ?? 0;
    return amount * widget.coin.coinDetails.price;
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
    final bool hasAmount = _amountCtrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.iconBackgroundLight,
              backgroundImage: widget.coin.coinDetails.thumb.isNotEmpty
                  ? NetworkImage(widget.coin.coinDetails.thumb)
                  : null,
              child: widget.coin.coinDetails.thumb.isEmpty
                  ? Text(
                      symbol[0],
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              'Send $symbol',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: const Icon(Icons.help_outline, color: AppColors.white),
          //   onPressed: _showNetworkInfo,
          // ),
          InkWell(
            onTap: _showNetworkInfo,
            child: CustomSvgImage(assetName: AppIcons.helpIcon, height: 20),
          ),
          const SizedBox(width: 8),

          CustomSvgImage(assetName: AppIcons.assetHistory, height: 20),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Network + One Time row ────────────────────────────────────
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: _showNetworkSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.iconBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.language, color: AppColors.textGreyLight, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _isAutoNetwork ? 'Select Network' : _selectedNetwork,
                          style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: <Widget>[
                      Text('One Time', style: TextStyle(color: AppColors.white, fontSize: 13)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_drop_down, color: AppColors.white, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // ── Address Card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Address',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onLongPress: () async {
                      final ClipboardData? data = await Clipboard.getData('text/plain');
                      if (data?.text != null && data!.text!.isNotEmpty) {
                        setState(() => _address = data.text!.trim());
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: _address.isEmpty
                          ? const Text(
                              'Long press to paste',
                              style: TextStyle(color: AppColors.textGreyLight, fontSize: 18),
                            )
                          : Text(
                              _address,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      _PillButton(
                        icon: const Icon(
                          CupertinoIcons.person_circle,
                          color: AppColors.white,
                          size: 16,
                        ),
                        label: 'Address book',
                        onTap: () => _showAddressBook(context),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      _PillButton(
                        icon: CustomSvgImage(
                          assetName: AppIcons.scanIcon,
                          color: AppColors.white,
                          height: 12,
                        ),
                        label: 'Scan',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // ── Withdrawal Amount Card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                border: _amountError != null ? Border.all(color: AppColors.red, width: 1) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'Withdrawal Amount',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _showAmountInfo,
                        child: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.textGreyLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: AppColors.textGreyLight,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (String v) {
                            _validateAmount(v);
                            setState(() {});
                          },
                        ),
                      ),
                      if (hasAmount)
                        GestureDetector(
                          onTap: () {
                            _amountCtrl.clear();
                            _validateAmount('');
                            setState(() {});
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.close, color: AppColors.textGreyLight, size: 20),
                          ),
                        ),
                      Text(
                        symbol,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _amountCtrl.text = available.toString();
                          _validateAmount(_amountCtrl.text);
                          setState(() {});
                        },
                        child: const Text(
                          'Max',
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Text(
                        '≈ ৳${_fiatValue.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.white, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      CustomSvgImage(assetName: AppIcons.editIcon, height: 13),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Text(
                        'Available',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        '${available.toStringAsFixed(8)} $symbol',
                        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textGreyLight, size: 18),
                    ],
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

            const SizedBox(height: AppSizes.md),

            // ── Caution Info collapsible ───────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _cautionExpanded = !_cautionExpanded),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Caution Info',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _cautionExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textGreyLight,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (_cautionExpanded) ...<Widget>[
              const SizedBox(height: AppSizes.sm),
              const Text(
                'Do not withdraw directly to a crowdfund or ICO. We will not credit your account with tokens from that sale.',
                style: TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: AppSizes.sm),
              RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    const TextSpan(
                      text: 'Do not transact with Sanctioned Entitles. ',
                      style: TextStyle(color: AppColors.textGreyLight, fontSize: 12, height: 1.5),
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Learn more',
                          style: TextStyle(
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
            ],

            const SizedBox(height: 120),
          ],
        ),
      ),

      // ── Sticky Bottom ──────────────────────────────────────────────────────
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.call_received, color: AppColors.textGreyLight, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Receive amount',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '${_receiveAmount.toStringAsFixed(8)} $symbol',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(Icons.percent, color: AppColors.textGreyLight, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Network fee',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '${_networkFee.toStringAsFixed(2)} $symbol',
                    style: const TextStyle(color: AppColors.white, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow.withValues(alpha: _canWithdraw ? 1.0 : 0.45),
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                    ),
                  ),
                  onPressed: () {
                    DeviceUtility.hapticFeedback();
                    if (!_canWithdraw) {
                      if (_address.isEmpty) {
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
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                          ),
                        )
                      : const Text(
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

  // ── Address book bottom sheet ────────────────────────────────────────────────
  void _showAddressBook(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (_) => _AddressBookSheet(
        coin: widget.coin,
        savedAddresses: _savedAddresses,
        addressService: _addressService,
        onSelect: (CryptoAddressModel addr) {
          Navigator.pop(context);
          _selectSavedAddress(addr);
        },
        onAddressAdded: _loadSavedAddresses,
      ),
    );
  }

  void _showNetworkSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (_) => NetworkSheetContent(
        networks: _getAvailableNetworks(),
        initialNetwork: _isAutoNetwork ? null : _selectedNetwork,
        coinSymbol: widget.coin.coinDetails.symbol,
        coinPrice: widget.coin.coinDetails.price,
        addressService: _addressService,
        isWithdraw: true,
        onSelect: (String net) {
          setState(() {
            _isAutoNetwork = false;
            _selectedNetwork = net;
          });
          _calculateNetworkFee();
        },
      ),
    );
  }

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
            _ConfirmRow(label: 'To', value: _formatAddress(_address)),
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

  Future<void> _executeWithdraw() async {
    setState(() => _isProcessing = true);
    try {
      final double withdrawAmount = double.parse(_amountCtrl.text);
      final String coinSymbol = widget.coin.coinDetails.symbol;
      await _walletController.withdrawCoin(coinSymbol: coinSymbol, amount: withdrawAmount);
      ToastManager.show(
        message: 'Withdrawal successful! $withdrawAmount $coinSymbol sent',
        backgroundColor: AppColors.greenContainer,
        textColor: AppColors.white,
        icon: const Icon(Icons.check_circle, color: AppColors.green),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) Get.back();
    } catch (e) {
      ToastManager.show(
        message: 'Withdrawal failed: ${e.toString()}',
        backgroundColor: AppColors.darkRed,
        textColor: AppColors.white,
        icon: const Icon(Icons.error, color: AppColors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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

// ── Address Book bottom sheet ──────────────────────────────────────────────────
class _AddressBookSheet extends StatefulWidget {
  final WalletCoinModel coin;
  final List<CryptoAddressModel> savedAddresses;
  final AddressStorageService addressService;
  final void Function(CryptoAddressModel) onSelect;
  final VoidCallback onAddressAdded;

  const _AddressBookSheet({
    required this.coin,
    required this.savedAddresses,
    required this.addressService,
    required this.onSelect,
    required this.onAddressAdded,
  });

  @override
  State<_AddressBookSheet> createState() => _AddressBookSheetState();
}

class _AddressBookSheetState extends State<_AddressBookSheet> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.82;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Handle ────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.iconBackgroundLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
            child: Row(
              children: <Widget>[
                CustomSvgImage(assetName: AppIcons.editIcon, height: 22),
                Expanded(
                  child: const Text(
                    'Select Address',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ).centered,
                ),
              ],
            ),
          ),
          // ── Tabs ──────────────────────────────────────────────────────
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            indicatorColor: AppColors.yellow,
            dividerColor: AppColors.iconBackground,
            dividerHeight: 1,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.textGreyLight,
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 15),
            tabs: const <Widget>[
              Tab(text: 'Address book'),
              Tab(text: 'Recently'),
            ],
          ),
          // const Divider(height: 1, color: AppColors.iconBackground),
          // ── Tab views ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: <Widget>[
                _AddressListTab(addresses: widget.savedAddresses, onSelect: widget.onSelect),
                _AddressListTab(addresses: const <CryptoAddressModel>[], onSelect: widget.onSelect),
              ],
            ),
          ),

          // ── Add New Address button ────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.sm + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await Get.to(
                    () => AddNewAddressScreen(coin: widget.coin),
                    transition: Transition.rightToLeft,
                  );
                  widget.onAddressAdded();
                },
                child: Text(
                  'Add New Address',
                  style: const TextStyle(fontSize: 16).copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressListTab extends StatelessWidget {
  final List<CryptoAddressModel> addresses;
  final void Function(CryptoAddressModel) onSelect;

  const _AddressListTab({required this.addresses, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.find_in_page_outlined, size: 64, color: AppColors.textGreyLight),
          SizedBox(height: AppSizes.md),
          Text(
            'No available address',
            style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
      itemCount: addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (_, int i) {
        final CryptoAddressModel addr = addresses[i];
        return GestureDetector(
          onTap: () => onSelect(addr),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.iconBackgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.yellow,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        addr.label ?? addr.network,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${addr.address.substring(0, addr.address.length > 12 ? 6 : addr.address.length)}...',
                        style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.iconBackgroundLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    addr.network,
                    style: const TextStyle(color: AppColors.textGreyLight, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Shared Pill Button ─────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Confirm row ────────────────────────────────────────────────────────────────
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
