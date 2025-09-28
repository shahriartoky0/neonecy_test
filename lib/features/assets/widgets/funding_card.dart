import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../controllers/assets_controller.dart';

class FundingCard extends GetView<AssetsController> {
  final String cryptoName;
  final String cryptoSymbol;
  final String balance;
  final String price;
  final String pnl;
  final String percentageChange;
  final String icon;

  const FundingCard({
    super.key,
    required this.cryptoName,
    required this.cryptoSymbol,
    required this.balance,
    required this.price,
    required this.pnl,
    required this.percentageChange,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header row with icon, name, and balance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Left side - Icon and name
            Row(
              children: <Widget>[
                // Crypto icon (using a circular container with a background color)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 14))),
                ),
                const SizedBox(width: 8),
                Text(
                  cryptoName,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Right side - Balance
            Text(
              balance,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Second row with crypto price and USD value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              cryptoSymbol,
              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
            ),
            Text(price, style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
          ],
        ),

        const SizedBox(height: AppSizes.sm),

        // Third row with Today's P&L and percentage change
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text("Available\nFreeze", style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
            Text(
              '$pnl ($percentageChange)',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}