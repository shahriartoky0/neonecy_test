// lib/features/assets/screens/asset_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/features/home/widgets/custom_refresher.dart';
import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart' show AppColors;
import '../../../core/design/app_icons.dart';
import '../../../core/design/app_images.dart';
import '../../../core/utils/device/device_utility.dart';
import '../../home/controllers/home_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/models/coin_wallet_model.dart';
import '../controllers/assets_controller.dart';
import '../widgets/add_fund_button_modal.dart';
import '../widgets/crypto_card.dart';
import '../widgets/send_button_modal.dart';
import '../widgets/tab_row.dart';
import 'asset_funding.dart';
import 'deposit_select_coin_screen.dart';

class AssetOverviewScreen extends GetView<AssetsController> {
  const AssetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final WalletController walletController = Get.find<WalletController>();

    return CustomGifRefreshWidget(
      onRefresh: () async {
        await controller.onRefresh();
        await walletController.fetchWalletCoins();
      },
      gifAssetPath: AppImages.loader,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  spacing: 5,
                  children: <Widget>[
                    Text(
                      'Est.Total Value(USD) ',
                      style: TextStyle(color: AppColors.textWhite.withOpacity(0.85)),
                    ),
                    CustomSvgImage(assetName: AppIcons.eye, height: 12),
                  ],
                ),
                Row(
                  spacing: AppSizes.md,
                  children: <Widget>[
                    clickableIcon(
                      icon: CustomSvgImage(assetName: AppIcons.assetsGraph, height: 18),
                      onTap: () {},
                    ),
                    clickableIcon(
                      icon: CustomSvgImage(assetName: AppIcons.assetHistory, height: 18),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            /// ========> Total Balance from Wallet =======>
            Row(
              children: <Widget>[
                Obx(() {
                  // Calculate total wallet value
                  final double totalValue = walletController.walletCoins.fold(
                    0.0,
                    (double sum, WalletCoinModel coin) =>
                        sum + (coin.quantity * coin.coinDetails.price),
                  );

                  return Text(
                    '\$ ${totalValue.toStringAsFixed(2)}',
                    style: context.txtTheme.displayMedium?.copyWith(fontSize: 26),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
                const SizedBox(width: 5),
                Text(
                  'USD',
                  style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const Icon(Icons.arrow_drop_down_sharp),
              ],
            ),
            const SizedBox(height: AppSizes.sm),

            /// ========> Total PNL from Wallet =======>
            Obx(() {
              // Calculate total PNL
              final double totalPnl = walletController.walletCoins.fold(
                0.0,
                (double sum, WalletCoinModel coin) => sum + coin.profitLoss,
              );

              final double totalPnlPercent = walletController.walletCoins.isNotEmpty
                  ? walletController.walletCoins.fold(
                          0.0,
                          (double sum, WalletCoinModel coin) => sum + coin.profitLossPercent,
                        ) /
                        walletController.walletCoins.length
                  : 0.0;

              final bool isPositive = totalPnl >= 0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Today's PNL ",
                    style: TextStyle(color: AppColors.white, fontSize: 11),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}\$${totalPnl.toStringAsFixed(8)} (${isPositive ? '+' : ''}${totalPnlPercent.toStringAsFixed(2)}%) ',
                    style: TextStyle(
                      color: isPositive ? AppColors.greenAccent : AppColors.red,
                      fontSize: 11,
                    ),
                  ),
                  const Text(">", style: TextStyle(color: AppColors.grey, fontSize: 11)),
                ],
              );
            }),

            const SizedBox(height: AppSizes.md),

            /// ==========> Action Buttons ===>
            Row(
              spacing: 8,
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    bgColor: AppColors.yellow,
                    textColor: AppColors.black,
                    labelText: 'Add Funds',
                    onTap: () => showAddFundModal(context),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    bgColor: AppColors.iconBackgroundLight,
                    textColor: AppColors.textWhite,
                    labelText: 'Send',
                    onTap: () {
                      sendButtonModal(context);
                    },
                  ),
                ),
                Expanded(
                  child: AppButton(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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

            /// ==========> Tab Row =========>
            TabRow(),

            /// ==========> Wallet Coins List =========>
            Obx(() {
              final RxList<WalletCoinModel> coins = walletController.walletCoins;

              if (coins.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                itemCount: coins.length,
                itemBuilder: (BuildContext context, int index) {
                  final WalletCoinModel walletCoin = coins[index];
                  final bool isPositive = walletCoin.profitLossPercent >= 0;

                  return CryptoCard(
                    cryptoName: walletCoin.coinDetails.name,
                    cryptoSymbol: walletCoin.coinDetails.symbol,
                    balance: _formatBalance(walletCoin.quantity),
                    price: '\$${walletCoin.coinDetails.price.toStringAsFixed(4)}',
                    pnl: '\$${walletCoin.profitLoss.toStringAsFixed(4)}',
                    percentageChange:
                        '(${isPositive ? '+' : ''}${walletCoin.profitLossPercent.toStringAsFixed(2)}%)',
                    iconImage: walletCoin.coinDetails.thumb,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Column(
                    children: <Widget>[
                      SizedBox(height: AppSizes.sm),
                      Divider(),
                    ],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatBalance(double balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else if (balance >= 1) {
      return balance.toStringAsFixed(2);
    } else if (balance >= 0.0001) {
      return balance.toStringAsFixed(4);
    } else {
      return balance.toStringAsFixed(8);
    }
  }

  Widget _buildEmptyState() {
    return Container(
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
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Start trading to add coins to your wallet',
            style: TextStyle(
              color: AppColors.textGreyLight.withOpacity(0.5),
              fontSize: AppSizes.fontSizeBodyS,
            ),
          ),
        ],
      ),
    );
  }

  Material clickableIcon({required Widget icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        splashColor: AppColors.primaryColor,
        onTap: () {
          DeviceUtility.hapticFeedback();
          onTap();
        },
        child: icon,
      ),
    );
  }
}
