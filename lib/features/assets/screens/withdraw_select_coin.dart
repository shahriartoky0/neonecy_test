// lib/features/assets/screens/withdraw_select_coin.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';
import 'package:neonecy_test/features/assets/screens/withdraw.dart';
import 'package:neonecy_test/features/wallet/controllers/wallet_controller.dart';
import 'package:neonecy_test/features/wallet/models/coin_wallet_model.dart';

class WithdrawSelectCoinScreen extends StatefulWidget {
  const WithdrawSelectCoinScreen({super.key});

  @override
  State<WithdrawSelectCoinScreen> createState() => _WithdrawSelectCoinScreenState();
}

class _WithdrawSelectCoinScreenState extends State<WithdrawSelectCoinScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final AddressStorageService _addressService = AddressStorageService();
  late final WalletController _wc;
  String _query = '';
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _wc = Get.find<WalletController>();
    ever(_wc.walletCoins, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<WalletCoinModel> walletCoins = _wc.walletCoins.toList();

    final List<WalletCoinModel> filtered = _query.isEmpty
        ? walletCoins
        : walletCoins
              .where(
                (WalletCoinModel c) =>
                    c.coinDetails.symbol.toLowerCase().contains(_query) ||
                    c.coinDetails.name.toLowerCase().contains(_query),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Select Coin',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: <Widget>[
          IconButton(
            icon: CustomSvgImage(assetName: AppIcons.search, color: AppColors.white, height: 20),
            onPressed: () => setState(() {
              _searchVisible = !_searchVisible;
              if (!_searchVisible) {
                _query = '';
                _searchCtrl.clear();
              }
            }),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Wallet filter chip ─────────────────────────────────────────
          GestureDetector(
            onTap: () => _showAccountSelector(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomSvgImage(assetName: AppIcons.walletIcon, color: AppColors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Spot + Funding + Earn Flexible',
                    style: TextStyle(color: AppColors.white, fontSize: 13),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, color: AppColors.white, size: 18),
                ],
              ),
            ),
          ),

          // ── Toggleable search bar ──────────────────────────────────────
          if (_searchVisible)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.sm),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                onChanged: (String v) => setState(() => _query = v.toLowerCase().trim()),
                decoration: InputDecoration(
                  hintText: 'Search Coins',
                  hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomSvgImage(assetName: AppIcons.search, color: AppColors.textGreyLight, height: 18),
                  ),
                  filled: true,
                  fillColor: AppColors.iconBackground,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.yellow, width: 1),
                  ),
                ),
              ),
            ),

          // ── Coin list ──────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty ? 'No coins in your wallet' : 'No coins found',
                      style: const TextStyle(color: AppColors.textGreyLight),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, int i) => _CoinListTile(coin: filtered[i], onTap: _navigate),
                  ),
          ),
        ],
      ),
    );
  }

  void _navigate(WalletCoinModel coin) {
    _addressService.addToWithdrawHistory(coin.coinDetails.symbol);
    Get.to(() => WithdrawScreen(coin: coin), transition: Transition.rightToLeft);
  }

  void _showAccountSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
      ),
      builder: (_) => const _AccountSelectorSheet(),
    );
  }
}

// ── Account selector bottom sheet ─────────────────────────────────────────────
class _AccountSelectorSheet extends StatefulWidget {
  const _AccountSelectorSheet();

  @override
  State<_AccountSelectorSheet> createState() => _AccountSelectorSheetState();
}

class _AccountSelectorSheetState extends State<_AccountSelectorSheet> {
  bool _spot = true;
  bool _funding = true;
  bool _earn = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.iconBackgroundLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Select withdrawal account',
            style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.md),
          _AccountCheckbox(
            label: 'Spot Account',
            value: _spot,
            onChanged: (bool? v) => setState(() => _spot = v ?? true),
          ),
          const SizedBox(height: AppSizes.sm),
          _AccountCheckbox(
            label: 'Funding Account',
            value: _funding,
            onChanged: (bool? v) => setState(() => _funding = v ?? true),
          ),
          const SizedBox(height: AppSizes.sm),
          _AccountCheckbox(
            label: 'Earn - Flexible Assets',
            value: _earn,
            onChanged: (bool? v) => setState(() => _earn = v ?? true),
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSizes.xs),
        ],
      ),
    );
  }
}

class _AccountCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _AccountCheckbox({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.iconBackgroundLight, width: 1),
                borderRadius: BorderRadius.circular(4),
                color: value ? AppColors.white : Colors.transparent,
              ),
              child: value ? const Icon(Icons.check, size: 16, color: AppColors.primaryColor) : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: AppColors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ── Coin list tile ─────────────────────────────────────────────────────────────
class _CoinListTile extends StatelessWidget {
  final WalletCoinModel coin;
  final void Function(WalletCoinModel) onTap;

  const _CoinListTile({required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double bdtValue = coin.quantity * coin.coinDetails.price;
    return InkWell(
      onTap: () => onTap(coin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.iconBackgroundLight,
              backgroundImage: coin.coinDetails.thumb.isNotEmpty
                  ? NetworkImage(coin.coinDetails.thumb)
                  : null,
              child: coin.coinDetails.thumb.isEmpty
                  ? Text(
                      coin.coinDetails.symbol[0],
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    coin.coinDetails.symbol,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.coinDetails.name,
                    style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  coin.quantity.toStringAsFixed(8),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '≈ ৳${bdtValue.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
