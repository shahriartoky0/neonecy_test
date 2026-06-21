import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';

class FundingCard extends StatelessWidget {
  final String cryptoName;
  final String cryptoSymbol;
  // quantity of coin held
  final String balance;
  // total USD value of holdings (e.g. "$59.82")
  final String price;
  // signed P&L amount (e.g. "+$0.6496" or "-$5.23")
  final String pnl;
  // PNL percentage including sign (e.g. "(+1.10%)" or "(-49.27%)")
  final String percentageChange;
  final String iconImage;

  const FundingCard({
    super.key,
    required this.cryptoName,
    required this.cryptoSymbol,
    required this.balance,
    required this.price,
    required this.pnl,
    required this.percentageChange,
    required this.iconImage,
  });

  bool get _isPositive => pnl.startsWith('+');

  @override
  Widget build(BuildContext context) {
    final Color pnlColor = _isPositive ? AppColors.greenAccent : AppColors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Coin icon
          _buildIcon(),
          const SizedBox(width: AppSizes.md),

          // All text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Row 1: symbol | balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      cryptoSymbol,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      balance,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Row 2: name | total value
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      cryptoName,
                      style: const TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Row 3: "Floating PNL" label | signed pnl + pct colored
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Floating PNL',
                      style: TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                      ),
                    ),
                    Text(
                      '$pnl$percentageChange',
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: AppSizes.fontSizeBodyS,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.iconBackground,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: iconImage,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Center(
            child: Text(
              cryptoSymbol.isNotEmpty ? cryptoSymbol[0] : '?',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
