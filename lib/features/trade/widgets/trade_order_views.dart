// lib/features/trade/widgets/trade_order_views.dart
// UI-only Recurring and Limit order views for the Trade > Convert tab.
// No backend integration — actions are placeholders.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';
import '../../assets/model/coin_model.dart';
import '../controllers/trade_controller.dart';
import 'coin_selection_modal.dart';

// ── Recurring ─────────────────────────────────────────────────────────────────

class RecurringOrderView extends GetView<TradeController> {
  const RecurringOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── From ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'From',
                    style: TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _availableBalance(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Obx(
                    () => _TokenChip(
                      coin: controller.fromCoin.value,
                      token: controller.fromToken.value,
                      onTap: () async {
                        final CoinItem? selectedCoin = await CoinSelectionBottomSheet.show(
                          context,
                          fromWallet: true,
                        );
                        if (selectedCoin != null) {
                          controller.selectFromCoin(selectedCoin);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '0.1 - 3200000',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: AppColors.textGreyLight.withValues(alpha: 0.5), thickness: 0.5),

        // ── To ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  children: <InlineSpan>[
                    TextSpan(text: 'To ('),
                    TextSpan(text: '100%', style: TextStyle(color: AppColors.green)),
                    TextSpan(text: '/100%)'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Obx(
                    () => _TokenChip(
                      coin: controller.toCoin.value,
                      token: controller.toToken.value,
                      onTap: () async {
                        final CoinItem? selectedCoin = await CoinSelectionBottomSheet.show(
                          context,
                          fromWallet: false,
                        );
                        if (selectedCoin != null) {
                          controller.selectToCoin(selectedCoin);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '100%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: AppColors.textGreyLight.withValues(alpha: 0.5), thickness: 0.5),
        const SizedBox(height: AppSizes.md),

        // ── Plan options ────────────────────────────────────────
        _labelValueRow(label: 'Frequency', value: 'Daily, 00:00 (UTC+6)'),
        const SizedBox(height: AppSizes.md),
        _labelValueRow(label: 'Target Wallet', value: 'Spot Account'),
        const SizedBox(height: AppSizes.md),
        GestureDetector(
          onTap: () {},
          child: const Row(
            children: <Widget>[
              Text(
                'Advanced Options',
                style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
              ),
              SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down, color: AppColors.textGreyLight, size: 18),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        _placeholderButton('Create a plan'),
        const SizedBox(height: AppSizes.xl),

        // ── Recurring plans ─────────────────────────────────────
        const Text(
          'Recurring Plan (0)',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.xxl),
        _noRecordsFound(),
        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  Widget _availableBalance() {
    return Obx(() {
      final double balance = controller.fromCoinBalance.value;
      final String coinSymbol = controller.fromCoin.value?.symbol ?? '';
      return Row(
        children: <Widget>[
          CustomSvgImage(assetName: AppIcons.walletIcon, color: AppColors.white),
          const SizedBox(width: 6),
          Text(
            coinSymbol.isNotEmpty
                ? '${controller.formatCoinAmount(balance)} $coinSymbol'
                : '0.00',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: AppColors.textWhite.withOpacity(0.7),
              decorationThickness: 1,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.add_circle, color: AppColors.yellow, size: 18),
        ],
      );
    });
  }
}

// ── Limit ─────────────────────────────────────────────────────────────────────

class LimitOrderView extends GetView<TradeController> {
  const LimitOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── From ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'From',
                    style: TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _availableBalance(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Obx(
                    () => _TokenChip(
                      coin: controller.fromCoin.value,
                      token: controller.fromToken.value,
                      onTap: () async {
                        final CoinItem? selectedCoin = await CoinSelectionBottomSheet.show(
                          context,
                          fromWallet: true,
                        );
                        if (selectedCoin != null) {
                          controller.selectFromCoin(selectedCoin);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '0.074 - 120000',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Max',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Swap ────────────────────────────────────────────────
        GestureDetector(
          onTap: controller.swapTokens,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Divider(color: AppColors.textGreyLight.withValues(alpha: 0.5), thickness: 0.5),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.textGreyLight.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CustomSvgImage(assetName: AppIcons.exchange, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),

        // ── To ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'To',
                style: TextStyle(
                  color: AppColors.textGreyLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Obx(
                    () => _TokenChip(
                      coin: controller.toCoin.value,
                      token: controller.toToken.value,
                      onTap: () async {
                        final CoinItem? selectedCoin = await CoinSelectionBottomSheet.show(
                          context,
                          fromWallet: false,
                        );
                        if (selectedCoin != null) {
                          controller.selectToCoin(selectedCoin);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '0.074 - 120000',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: AppColors.textGreyLight.withValues(alpha: 0.5), thickness: 0.5),

        // ── Price ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Price',
                style: TextStyle(
                  color: AppColors.textGreyLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final CoinItem? fromCoin = controller.fromCoin.value;
                final CoinItem? toCoin = controller.toCoin.value;
                final double? rate =
                    fromCoin != null && toCoin != null && fromCoin.price > 0 && toCoin.price > 0
                        ? toCoin.price / fromCoin.price
                        : null;
                return Row(
                  children: <Widget>[
                    _TokenChip(
                      coin: fromCoin,
                      token: controller.fromToken.value,
                      showArrow: false,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rate != null ? controller.formatCoinAmount(rate) : '--',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        Divider(color: AppColors.textGreyLight.withValues(alpha: 0.5), thickness: 0.5),
        const SizedBox(height: AppSizes.md),

        // ── Expires ─────────────────────────────────────────────
        _labelValueRow(label: 'Expires in', value: 'Expires in 30 days'),
        const SizedBox(height: AppSizes.lg),

        _placeholderButton('Preview'),
        const SizedBox(height: AppSizes.xl),

        // ── Open orders ─────────────────────────────────────────
        const Text(
          'Open Orders (0)',
          style: TextStyle(
            color: AppColors.white,
            fontSize: AppSizes.fontSizeBodyM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.xxl),
        _noRecordsFound(),
        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  Widget _availableBalance() {
    return Obx(() {
      final double balance = controller.fromCoinBalance.value;
      final String coinSymbol = controller.fromCoin.value?.symbol ?? '';
      return Row(
        children: <Widget>[
          CustomSvgImage(assetName: AppIcons.walletIcon, color: AppColors.white),

          const SizedBox(width: 6),
          Text(
            coinSymbol.isNotEmpty
                ? '${controller.formatCoinAmount(balance)} $coinSymbol'
                : '0.00',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: AppColors.textWhite.withOpacity(0.7),
              decorationThickness: 1,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.add_circle, color: AppColors.yellow, size: 18),
        ],
      );
    });
  }
}

// ── Shared pieces ─────────────────────────────────────────────────────────────

Widget _labelValueRow({required String label, required String value}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(label, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 13)),
      GestureDetector(
        onTap: () {},
        child: Row(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.white, size: 20),
          ],
        ),
      ),
    ],
  );
}

Widget _placeholderButton(String label) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.yellow.withOpacity(0.4),
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textGreyLight,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _noRecordsFound() {
  return Center(
    child: Column(
      children: <Widget>[
        Icon(
          Icons.description_outlined,
          size: 64,
          color: AppColors.textGreyLight.withValues(alpha: 0.4),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          'No records found',
          style: TextStyle(
            color: AppColors.textGreyLight.withValues(alpha: 0.7),
            fontSize: AppSizes.fontSizeBodyM,
          ),
        ),
      ],
    ),
  );
}

class _TokenChip extends StatelessWidget {
  final CoinItem? coin;
  final String token;
  final bool showArrow;
  final VoidCallback onTap;

  const _TokenChip({
    required this.coin,
    required this.token,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (coin != null)
              SizedBox(
                width: 30,
                height: 30,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: coin!.thumb,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) => Container(
                      color: AppColors.iconBackgroundLight,
                      child: Center(
                        child: Text(
                          token.isNotEmpty ? token.substring(0, 1) : '',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (BuildContext context, String url, Object error) => Container(
                      color: AppColors.iconBackgroundLight,
                      child: Center(
                        child: Text(
                          token.isNotEmpty ? token.substring(0, 1) : '',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    token.isNotEmpty && token != 'Select a Coin' ? token.substring(0, 1) : '',
                    style: const TextStyle(
                      color: AppColors.iconBackgroundLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              token == 'Select a Coin' ? '-- ' : token,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_drop_down, color: AppColors.textWhite, size: 26),
          ],
        ),
      ),
    );
  }
}
