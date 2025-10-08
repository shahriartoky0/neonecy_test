// lib/features/trade/widgets/conversion_success_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  State<ConversionSuccessScreen> createState() => _ConversionSuccessScreenState();
}

class _ConversionSuccessScreenState extends State<ConversionSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final double fromValue = _parseAmount(widget.fromAmount);
    final double rate = _parseAmount(widget.toAmount) / fromValue;

    return Scaffold(
       body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              // Title
              const Text(
                'Conversion Details',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: AppSizes.fontSizeH3,
                   
                ),
              ),

              const SizedBox(height: AppSizes.xxl),

              // Main Amount
              Text(
                '${widget.toAmount} ${widget.toCoin.symbol}',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSizes.md),

              // Completed Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(CupertinoIcons.checkmark_alt_circle, color: AppColors.green, size: 18),
                    SizedBox(width: AppSizes.xs),
                    Text(
                      'Completed',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 14,
                         
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),
              Divider(),
              // Details Container
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Type
                  _buildDetailRow('Type', 'Instant'),

                  const SizedBox(height: AppSizes.md),
                  const Divider(color: Color(0xFF3A4552), height: 1),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Pay From',
                    style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: AppSizes.fontSizeBodyS,
                    ),
                  ),
                  SizedBox(height: AppSizes.sm),
                  // Pay From
                  Container(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: AppSizes.sm),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textGreyLight.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Spot Account',
                          style: TextStyle(
                            color: AppColors.textGreyLight,
                            fontSize: AppSizes.fontSizeBodyS,
                           ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            const SizedBox(height: 2),
                            Text(
                              '${widget.fromAmount} ${widget.fromCoin.symbol}',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: AppSizes.fontSizeBodyS,
                                 
                              ),
                            ),
                            Text(
                              '1 ${widget.fromCoin.symbol} ≈ ${_formatRate(rate)} ${widget.toCoin.symbol}',
                              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.md),
                  const Divider(color: Color(0xFF3A4552), height: 1),
                  const SizedBox(height: AppSizes.md),

                  // Transaction
                  _buildDetailRow('Transaction', '0.00 ${widget.toCoin.symbol}'),

                  const SizedBox(height: AppSizes.md),
                  const Divider(color: Color(0xFF3A4552), height: 1),
                  const SizedBox(height: AppSizes.md),

                  // Trade Date
                  _buildDetailRow('Trade Date', currentDate),
                ],
              ),

              const Spacer(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isComplex = false,
    Widget? complexWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: AppColors.textGreyLight, fontSize: AppSizes.fontSizeBodyS),
        ),
        if (isComplex && complexWidget != null)
          complexWidget
        else
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 15,
               
            ),
            textAlign: TextAlign.right,
          ),
      ],
    );
  }

  double _parseAmount(String amount) {
    return double.tryParse(amount.replaceAll(',', '')) ?? 0.0;
  }

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return rate.toStringAsFixed(2);
    } else if (rate >= 1) {
      return rate.toStringAsFixed(4);
    } else if (rate >= 0.0001) {
      return rate.toStringAsFixed(6);
    } else if (rate > 0) {
      return rate.toStringAsFixed(8);
    }
    return '0';
  }
}
