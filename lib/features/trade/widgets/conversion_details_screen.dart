// lib/features/trade/widgets/conversion_success_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/features/mainBottomNav/controllers/main_bottom_nav_controller.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../assets/model/coin_model.dart';

class ConversionSuccessScreen extends StatefulWidget {
  final CoinItem fromCoin;
  final CoinItem toCoin;
  final String fromAmount;
  final String toAmount;

  const ConversionSuccessScreen({
    super.key,
    required this.fromCoin,
    required this.toCoin,
    required this.fromAmount,
    required this.toAmount,
  });

  @override
  State<ConversionSuccessScreen> createState() =>
      _ConversionSuccessScreenState();
}

class _ConversionSuccessScreenState extends State<ConversionSuccessScreen> {
  bool _autoSave = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Get.find<MainBottomNavController>().resetToHomePage();
        Get.offAllNamed(AppRoutes.mainBottomScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final double fromValue = _parseAmount(widget.fromAmount);
    final double toValue = _parseAmount(widget.toAmount);
    final double rate = fromValue > 0 ? toValue / fromValue : 0;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md, vertical: AppSizes.sm),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Text(
                    'Conversion Details',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppSizes.fontSizeH3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.find<MainBottomNavController>().resetToHomePage();
                        Get.offAllNamed(AppRoutes.mainBottomScreen);
                      },
                      child: const Icon(Icons.close,
                          color: AppColors.textGreyLight, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // ── Main received amount ───────────────────────────────
            Text(
              '${widget.toAmount} ${widget.toCoin.symbol}',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),

            // ── Completed badge ────────────────────────────────────
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.check_circle, color: AppColors.green, size: 18),
                SizedBox(width: AppSizes.xs),
                Text(
                  'Completed',
                  style:
                      TextStyle(color: AppColors.green, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),
            const Divider(color: AppColors.iconBackground),

            // ── Detail rows ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg, vertical: AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildDetailRow('Type', 'INSTANT'),
                    const SizedBox(height: AppSizes.md),
                    const Divider(
                        color: AppColors.iconBackground, height: 1),
                    const SizedBox(height: AppSizes.md),

                    // ── Pay From ──────────────────────────────────
                    const Text(
                      'Pay From',
                      style: TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.md,
                        horizontal: AppSizes.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.textGreyLight
                                .withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Funding Account',
                                style: TextStyle(
                                  color: AppColors.textGreyLight,
                                  fontSize: AppSizes.fontSizeBodyS,
                                ),
                              ),
                              Text(
                                '${widget.fromAmount} ${widget.fromCoin.symbol}',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: AppSizes.fontSizeBodyS,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '1 ${widget.fromCoin.symbol} = ${_formatRate(rate)} ${widget.toCoin.symbol} ⇄',
                              style: const TextStyle(
                                  color: AppColors.textGreyLight,
                                  fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.md),
                    const Divider(
                        color: AppColors.iconBackground, height: 1),
                    const SizedBox(height: AppSizes.md),

                    _buildDetailRow('Transaction Fees',
                        '0.00 ${widget.toCoin.symbol}'),

                    const SizedBox(height: AppSizes.md),
                    const Divider(
                        color: AppColors.iconBackground, height: 1),
                    const SizedBox(height: AppSizes.md),

                    _buildDetailRow('Trade Date', currentDate),

                    const SizedBox(height: AppSizes.lg),

                    // ── Auto-save toggle box ──────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md, vertical: AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.savings_outlined,
                              color: AppColors.yellow,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          const Expanded(
                            child: Text(
                              'Automatically save your purchased assets and earn interest every minute. You can redeem anytime.',
                              style: TextStyle(
                                color: AppColors.textGreyLight,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Switch(
                            value: _autoSave,
                            onChanged: (v) =>
                                setState(() => _autoSave = v),
                            activeColor: AppColors.yellow,
                            inactiveThumbColor: AppColors.textGreyLight,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.xl),

                    // ── Share on Binance Square ────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.share_outlined,
                                color: AppColors.textGreyLight, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Share on Binance Square',
                              style: TextStyle(
                                color: AppColors.textGreyLight,
                                fontSize: AppSizes.fontSizeBodyS,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textGreyLight,
              fontSize: AppSizes.fontSizeBodyS),
        ),
        Text(
          value,
          style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: AppSizes.fontSizeBodyS,
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  double _parseAmount(String amount) =>
      double.tryParse(amount.replaceAll(',', '')) ?? 0.0;

  String _formatRate(double rate) {
    if (rate >= 1000) return rate.toStringAsFixed(2);
    if (rate >= 1) return rate.toStringAsFixed(5);
    if (rate >= 0.0001) return rate.toStringAsFixed(6);
    if (rate > 0) return rate.toStringAsFixed(8);
    return '0';
  }
}
