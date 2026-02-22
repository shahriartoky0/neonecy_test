// lib/features/assets/screens/withdraw/withdraw_select_coin_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _wc = Get.find<WalletController>();
    // ✅ Use ever() to call setState when walletCoins changes.
    // This avoids Obx entirely — Obx inside a StatefulWidget with
    // conditional early-returns loses track of observables and crashes.
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
    // Read plain list — no Obx needed, ever() above handles reactivity
    final List<WalletCoinModel> walletCoins = _wc.walletCoins.toList();

    final List<String> history = _addressService.getRecentWithdrawSymbols();
    final List<WalletCoinModel> historyCo = history
        .map((String s) => walletCoins.firstWhereOrNull((WalletCoinModel c) => c.coinDetails.symbol == s))
        .whereType<WalletCoinModel>()
        .toList();

    final List<WalletCoinModel> filtered = _query.isEmpty
        ? <WalletCoinModel>[]
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Search ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.xs, AppSizes.md, AppSizes.sm),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              onChanged: (String v) => setState(() => _query = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'Search Coins',
                hintStyle: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight, size: 20),
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

          // ── Body — no Obx, ever() in initState handles reactivity ────
          Expanded(
            child: _query.isNotEmpty
                ? _SearchResults(coins: filtered, onTap: _navigate)
                : _DefaultView(
                    historyCo: historyCo,
                    allCoins: walletCoins,
                    onTap: _navigate,
                    onClearHistory: () {
                      _addressService.clearWithdrawHistory();
                      setState(() {});
                    },
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
}

// ── Search Results ─────────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final List<WalletCoinModel> coins;
  final void Function(WalletCoinModel) onTap;

  const _SearchResults({required this.coins, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const Center(
        child: Text(
          'No coins found in your wallet',
          style: TextStyle(color: AppColors.textGreyLight),
        ),
      );
    }
    return ListView.builder(
      itemCount: coins.length,
      itemBuilder: (_, int i) => _CoinListTile(coin: coins[i], onTap: onTap),
    );
  }
}

// ── Default View ───────────────────────────────────────────────────────────
class _DefaultView extends StatelessWidget {
  final List<WalletCoinModel> historyCo;
  final List<WalletCoinModel> allCoins;
  final void Function(WalletCoinModel) onTap;
  final VoidCallback onClearHistory;

  const _DefaultView({
    required this.historyCo,
    required this.allCoins,
    required this.onTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        if (historyCo.isNotEmpty) ...<Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(
              label: 'Search History',
              trailing: GestureDetector(
                onTap: onClearHistory,
                child:   const Icon(CupertinoIcons.delete, color: AppColors.textGreyLight, size: 15),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: historyCo.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
                itemBuilder: (_, int i) {
                  final WalletCoinModel coin = historyCo[i];
                  return GestureDetector(
                    onTap: () => onTap(coin),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        coin.coinDetails.symbol,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
        ],

        SliverToBoxAdapter(
          child: _SectionHeader(
            label: 'Coin List',
            trailing: const Icon(Icons.sort_by_alpha, color: AppColors.textGreyLight, size: 18),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int i) => _CoinListTile(coin: allCoins[i], onTap: onTap),
            childCount: allCoins.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSizes.xxxL)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _SectionHeader({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xs),
    child: Row(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class _CoinListTile extends StatelessWidget {
  final WalletCoinModel coin;
  final void Function(WalletCoinModel) onTap;

  const _CoinListTile({required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double usdValue = coin.quantity * coin.coinDetails.price;
    return InkWell(
      onTap: () => onTap(coin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
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
                  coin.quantity.toStringAsFixed(coin.quantity >= 1 ? 2 : 8),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '≈ \$${usdValue.toStringAsFixed(2)}',
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
