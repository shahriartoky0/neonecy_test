// lib/features/assets/screens/asset_funding_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/features/assets/controllers/assets_controller.dart';
import 'package:neonecy_test/features/home/controllers/home_controller.dart';
import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart' show AppColors;
import '../../../core/design/app_icons.dart';
import '../../../core/design/app_images.dart';
import '../../../core/utils/device/device_utility.dart';
import '../../home/widgets/custom_refresher.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/models/coin_wallet_model.dart';
import '../widgets/add_fund_button_modal.dart';
import '../widgets/add_fund_modal_tile.dart';
import '../widgets/funding_card.dart';
import '../widgets/send_button_modal.dart';
import 'deposit_select_coin_screen.dart';

class AssetFundingScreen extends GetView<AssetsController> {
  const AssetFundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.find<WalletController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header row ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Est.Total Value(USD) ',
                    style: TextStyle(color: AppColors.textWhite.withOpacity(0.85), fontSize: 12),
                  ),
                  CustomSvgImage(assetName: AppIcons.eye, height: 12),
                ],
              ),
              clickableIcon(
                icon: CustomSvgImage(assetName: AppIcons.assetHistory, height: 20),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // ── Total balance ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Obx(() {
                final double total = walletController.walletCoins.fold(
                  0.0,
                  (s, c) => s + c.quantity * c.coinDetails.price,
                );
                return Text(
                  '\$ ${total.toStringAsFixed(2)}',
                  style: context.txtTheme.displayMedium?.copyWith(fontSize: 28),
                  overflow: TextOverflow.ellipsis,
                );
              }),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'USD',
                  style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.white),
                ),
              ),
              const Icon(Icons.arrow_drop_down_sharp, color: AppColors.white),
            ],
          ),
          const SizedBox(height: AppSizes.xs),

          // ── Today's PNL ──────────────────────────────────────────────
          Obx(() {
            final coins = walletController.walletCoins;
            final pnl = coins.fold(0.0, (s, c) => s + c.profitLoss);
            final pnlPct = coins.isNotEmpty
                ? coins.fold(0.0, (s, c) => s + c.profitLossPercent) / coins.length
                : 0.0;
            final pos = pnl >= 0;
            return Row(
              children: <Widget>[
                const Text(
                  "Today's PNL ",
                  style: TextStyle(color: AppColors.textGreyLight, fontSize: 11),
                ),
                Text(
                  '${pos ? '+' : ''}\$${pnl.toStringAsFixed(6)} '
                  '(${pos ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: pos ? AppColors.greenAccent : AppColors.red,
                    fontSize: 11,
                  ),
                ),
                const Text(' >', style: TextStyle(color: AppColors.textGreyLight, fontSize: 11)),
              ],
            );
          }),

          const SizedBox(height: AppSizes.md),

          // ── Action buttons ───────────────────────────────────────────
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  bgColor: AppColors.yellow,
                  textColor: AppColors.black,
                  labelText: 'Add Funds',
                  onTap: () => showAddFundModal(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  bgColor: AppColors.iconBackgroundLight,
                  textColor: AppColors.textWhite,
                  labelText: 'Send',
                  onTap: () => sendButtonModal(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  bgColor: AppColors.iconBackgroundLight,
                  textColor: AppColors.textWhite,
                  labelText: 'Transfer',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          const Divider(),

          // ── Balances header ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Balances', style: context.txtTheme.headlineMedium),
              const Icon(CupertinoIcons.search, color: AppColors.white),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Coins list ───────────────────────────────────────────────
          Obx(() {
            final coins = walletController.walletCoins;
            final filtered = controller.lessThanDollarItems.value
                ? coins.where((c) => c.quantity * c.coinDetails.price >= 1.0).toList()
                : coins.toList();

            if (filtered.isEmpty) return _buildEmptyState();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final wc = filtered[index];
                final totalValue = wc.quantity * wc.coinDetails.price;
                final isPos = wc.profitLossPercent >= 0;
                return FundingCard(
                  cryptoName: wc.coinDetails.name,
                  cryptoSymbol: wc.coinDetails.symbol,
                  balance: _formatBalance(wc.quantity),
                  price: '\$${wc.coinDetails.price.toStringAsFixed(4)}',
                  pnl: '\$${totalValue.toStringAsFixed(2)}',
                  percentageChange: isPos
                      ? '+${wc.profitLossPercent.toStringAsFixed(2)}%'
                      : '${wc.profitLossPercent.toStringAsFixed(2)}%',
                  iconImage: wc.coinDetails.thumb,
                );
              },
              separatorBuilder: (_, __) => const Divider(),
            );
          }),
        ],
      ),
    );
  }

  String _formatBalance(double b) {
    if (b >= 1e6) return '${(b / 1e6).toStringAsFixed(2)}M';
    if (b >= 1e3) return '${(b / 1e3).toStringAsFixed(2)}K';
    if (b >= 1) return b.toStringAsFixed(2);
    if (b >= 0.0001) return b.toStringAsFixed(4);
    return b.toStringAsFixed(8);
  }

  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.all(AppSizes.xl),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 64,
          color: AppColors.textGreyLight.withOpacity(0.5),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          'No coins in your wallet yet',
          style: TextStyle(
            color: AppColors.textGreyLight.withOpacity(0.7),
            fontSize: AppSizes.fontSizeBodyM,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Tap Add Funds to get started',
          style: TextStyle(
            color: AppColors.textGreyLight.withOpacity(0.5),
            fontSize: AppSizes.fontSizeBodyS,
          ),
        ),
      ],
    ),
  );

  Material clickableIcon({required Widget icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        onTap: () {
          DeviceUtility.hapticFeedback();
          onTap();
        },
        child: icon,
      ),
    );
  }
}


