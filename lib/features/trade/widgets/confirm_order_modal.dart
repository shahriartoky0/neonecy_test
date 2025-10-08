// lib/features/trade/widgets/confirm_order_dialog.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../assets/model/coin_model.dart';
import 'conversion_details_screen.dart';

class ConfirmOrderDialog {
  static Future<bool?> show(
    BuildContext context, {
    required CoinItem fromCoin,
    required CoinItem toCoin,
    required String fromAmount,
    required String toAmount,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ConfirmOrderBottomSheet(
        fromCoin: fromCoin,
        toCoin: toCoin,
        fromAmount: fromAmount,
        toAmount: toAmount,
      ),
    );
  }
}

class _ConfirmOrderBottomSheet extends StatelessWidget {
  final CoinItem fromCoin;
  final CoinItem toCoin;
  final String fromAmount;
  final String toAmount;

  const _ConfirmOrderBottomSheet({
    required this.fromCoin,
    required this.toCoin,
    required this.fromAmount,
    required this.toAmount,
  });

  @override
  Widget build(BuildContext context) {
    final double fromUSD = _parseAmount(fromAmount) * fromCoin.price;
    final double toUSD = _parseAmount(toAmount) * toCoin.price;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXxl)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confirm Order',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppSizes.fontSizeH3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    color: AppColors.textGreyLight,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.lg),

              // From Section
              _buildCoinSection(
                label: 'From',
                coin: fromCoin,
                amount: fromAmount,
                usdValue: fromUSD,
              ),

              const SizedBox(height: AppSizes.md),

              // To Section
              _buildCoinSection(label: 'To', coin: toCoin, amount: toAmount, usdValue: toUSD),

              const SizedBox(height: AppSizes.lg),

              // Divider
              const Divider(color: AppColors.iconBackground, thickness: 1),

              const SizedBox(height: AppSizes.md),

              // Type
              _buildInfoRow('Type', 'Instant'),

              const SizedBox(height: AppSizes.sm),

              // Transaction Fees
              _buildInfoRow('Transaction Fees', '0.1%', valueColor: AppColors.textGreyLight),

              const SizedBox(height: AppSizes.sm),

              // Rate
              _buildInfoRow('Rate', _buildRateText(), valueColor: AppColors.textGreyLight),

              const SizedBox(height: AppSizes.xl),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                /// ======= Here the conversion details page for couple of seconds
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: AppSizes.fontSizeBodyM, fontWeight: FontWeight.w700),
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

  Widget _buildCoinSection({
    required String label,
    required CoinItem coin,
    required String amount,
    required double usdValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textGreyLight, fontSize: AppSizes.fontSizeBodyS),
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            // Coin Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.iconBackground, shape: BoxShape.circle),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: coin.thumb,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: label == 'From' ? AppColors.green : AppColors.red,
                    child: Center(
                      child: Text(
                        coin.symbol.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            // Coin Symbol
            Text(
              coin.symbol,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: AppSizes.fontSizeBodyM,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Amount and USD
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' \$${usdValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: AppSizes.fontSizeBodyS,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textGreyLight, fontSize: AppSizes.fontSizeBodyS),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textWhite,
            fontSize: AppSizes.fontSizeBodyS,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _buildRateText() {
    final double fromValue = _parseAmount(fromAmount);
    final double toValue = _parseAmount(toAmount);

    if (fromValue > 0) {
      final double rate = toValue / fromValue;
      return '1 ${fromCoin.symbol} ≈ ${_formatAmount(rate)} ${toCoin.symbol}';
    }
    return '1 ${fromCoin.symbol} ≈ 0 ${toCoin.symbol}';
  }

  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount >= 1) {
      return amount.toStringAsFixed(4);
    } else if (amount >= 0.0001) {
      return amount.toStringAsFixed(6);
    } else if (amount > 0) {
      return amount.toStringAsFixed(8);
    }
    return '0';
  }
}
