// lib/features/assets/screens/deposit/deposit_select_coin_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/utils/address_storage_service.dart';
import 'package:neonecy_test/features/assets/model/coin_model.dart';
import 'package:neonecy_test/features/wallet/controllers/wallet_controller.dart';

import 'deposit_address.dart';

class DepositSelectCoinScreen extends StatefulWidget {
  const DepositSelectCoinScreen({super.key});

  @override
  State<DepositSelectCoinScreen> createState() =>
      _DepositSelectCoinScreenState();
}

class _DepositSelectCoinScreenState extends State<DepositSelectCoinScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final AddressStorageService _addressService = AddressStorageService();
  String _query = '';

  static const List<String> _trendingSymbols = [
    'BTC', 'ETH', 'USDT', 'BNB',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Master coin list: wallet coins first then available ────────────────────
  List<CoinItem> _buildMasterList(WalletController wc) {
    final walletCoins = wc.walletCoins.map((w) => w.coinDetails).toList();
    final extras = wc.availableCoins
        .where((c) => walletCoins.every((w) => w.symbol != c.symbol))
        .toList();
    return [...walletCoins, ...extras];
  }

  @override
  Widget build(BuildContext context) {
    final WalletController wc = Get.find<WalletController>();

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
          style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // ── Search ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.xs, AppSizes.md, AppSizes.sm),
            child: TextField(
              controller: _searchCtrl,
              style:
              const TextStyle(color: AppColors.white, fontSize: 14),
              onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Search Coins',
                hintStyle: const TextStyle(
                    color: AppColors.textGreyLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textGreyLight, size: 20),
                filled: true,
                fillColor: AppColors.iconBackground,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10),
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
                  borderSide: const BorderSide(
                      color: AppColors.yellow, width: 1),
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              final allCoins = _buildMasterList(wc);

              if (_query.isNotEmpty) {
                final filtered = allCoins
                    .where((c) =>
                c.symbol.toLowerCase().contains(_query) ||
                    c.name.toLowerCase().contains(_query))
                    .toList();
                return _SearchResults(
                  coins: filtered,
                  addressService: _addressService,
                  onTap: _navigate,
                );
              }

              final history = _addressService.getRecentDepositSymbols();
              final historyCo = history
                  .map((s) => allCoins
                  .firstWhereOrNull((c) => c.symbol == s))
                  .whereType<CoinItem>()
                  .toList();

              final trending = _trendingSymbols
                  .map((s) => allCoins
                  .firstWhereOrNull((c) => c.symbol == s))
                  .whereType<CoinItem>()
                  .toList();

              return _DefaultView(
                historyCo: historyCo,
                trendingCoins: trending,
                allCoins: allCoins,
                addressService: _addressService,
                onTap: _navigate,
                onClearHistory: () {
                  _addressService.clearDepositHistory();
                  setState(() {});
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _navigate(CoinItem coin) {
    _addressService.addToDepositHistory(coin.symbol);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => DepositAddressScreen(coin: coin)),
    );
  }
}

// ── Search Results ─────────────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final List<CoinItem> coins;
  final AddressStorageService addressService;
  final void Function(CoinItem) onTap;

  const _SearchResults(
      {required this.coins,
        required this.addressService,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const Center(
        child: Text('No coins found',
            style: TextStyle(color: AppColors.textGreyLight)),
      );
    }
    return ListView.builder(
      itemCount: coins.length,
      itemBuilder: (_, i) => _CoinListTile(
        coin: coins[i],
        addressService: addressService,
        onTap: onTap,
      ),
    );
  }
}

// ── Default View with History / Trending / Alphabetical ───────────────────────
class _DefaultView extends StatelessWidget {
  final List<CoinItem> historyCo;
  final List<CoinItem> trendingCoins;
  final List<CoinItem> allCoins;
  final AddressStorageService addressService;
  final void Function(CoinItem) onTap;
  final VoidCallback onClearHistory;

  const _DefaultView({
    required this.historyCo,
    required this.trendingCoins,
    required this.allCoins,
    required this.addressService,
    required this.onTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    // Build alphabetical groups (skip trending symbols to avoid duplication)
    final Map<String, List<CoinItem>> grouped = {};
    for (final c in allCoins) {
      final key = RegExp(r'[0-9]').hasMatch(c.symbol[0])
          ? c.symbol[0]
          : c.symbol[0].toUpperCase();
      grouped.putIfAbsent(key, () => []).add(c);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return CustomScrollView(
      slivers: [
        // History chips
        if (historyCo.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(
              label: 'History',
              trailing: GestureDetector(
                onTap: onClearHistory,
                child: const Icon(Icons.delete_outline,
                    color: AppColors.textGreyLight, size: 18),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md),
                itemCount: historyCo.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: AppSizes.sm),
                itemBuilder: (_, i) {
                  final coin = historyCo[i];
                  return GestureDetector(
                    onTap: () => onTap(coin),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        coin.symbol,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: AppSizes.md)),
        ],

        // Trending
        const SliverToBoxAdapter(
            child: _SectionHeader(label: 'Trending')),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (_, i) => _CoinListTile(
              coin: trendingCoins[i],
              addressService: addressService,
              onTap: onTap,
            ),
            childCount: trendingCoins.length,
          ),
        ),

        // Divider between trending and alphabetical
        const SliverToBoxAdapter(
          child: Divider(
              color: AppColors.iconBackground, thickness: 6, height: 24),
        ),

        // Alphabetical list with sticky-style section letters
        for (final key in sortedKeys) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xs),
              child: Text(
                key,
                style: const TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (_, i) => _CoinListTile(
                coin: grouped[key]![i],
                addressService: addressService,
                onTap: onTap,
              ),
              childCount: grouped[key]!.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.xxxL)),
      ],
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _SectionHeader({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xs),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Individual coin row ────────────────────────────────────────────────────────
class _CoinListTile extends StatelessWidget {
  final CoinItem coin;
  final AddressStorageService addressService;
  final void Function(CoinItem) onTap;

  const _CoinListTile(
      {required this.coin,
        required this.addressService,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasAddr =
        addressService.getAddressesForCoin(coin.symbol).isNotEmpty;

    return InkWell(
      onTap: () => onTap(coin),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: 10),
        child: Row(
          children: [
            // Coin avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.iconBackgroundLight,
              backgroundImage: coin.thumb.isNotEmpty
                  ? NetworkImage(coin.thumb)
                  : null,
              child: coin.thumb.isEmpty
                  ? Text(coin.symbol[0],
                  style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),

            // Name + symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        coin.symbol,
                        style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),

                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(coin.name,
                      style: const TextStyle(
                          color: AppColors.textGreyLight,
                          fontSize: 12)),
                ],
              ),
            ),

            // Suspended badge placeholder
            const Icon(Icons.chevron_right,
                color: AppColors.textGreyLight, size: 18),
          ],
        ),
      ),
    );
  }
}