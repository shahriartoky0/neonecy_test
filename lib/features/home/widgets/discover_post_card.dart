import 'package:flutter/material.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';

class StockCard extends StatelessWidget {
  final String username;
  final String timeAgo;
  final String symbol;
  final String question;
  final String imagePath;
  final String priceChange;
  final bool isPositive;
  final int comments;
  final int likes;
  final int reposts;
  final int shares;

  const StockCard({
    super.key,
    required this.username,
    required this.timeAgo,
    required this.symbol,
    required this.question,
    required this.imagePath,
    required this.priceChange,
    required this.isPositive,
    required this.comments,
    required this.likes,
    required this.reposts,
    required this.shares,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              // Profile Icon
              CustomSvgImage(assetName: AppIcons.discoverProfile, height: AppSizes.iconXl),
              const SizedBox(width: 12),
              // Username and time
              Expanded(
                child: Row(
                  spacing: AppSizes.sm,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(timeAgo, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    const Text('Bullish', style: TextStyle(color: AppColors.green, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '\$$symbol ',
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: question,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Chart Image
        Container(
          width: double.infinity,
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.sm),
            color: AppColors.grey.withValues(alpha: 0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.sm),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  child: const Center(
                    child: Icon(Icons.show_chart, color: Colors.white54, size: 48),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Price Change
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(symbol),
              Text(
                ' $priceChange',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _ActionItem(assetPath: AppIcons.discoverComment, count: comments),
              _ActionItem(assetPath: AppIcons.discoverLike, count: likes),
              _ActionItem(assetPath: AppIcons.discoverRepeat, count: reposts),
              _ActionItem(assetPath: AppIcons.discoverShare, count: shares),
            ],
          ),
        ),

        // Actions Bar
        const SizedBox(height: AppSizes.md),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String assetPath;
  final int count;

  const _ActionItem({required this.assetPath, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Icon(assetPath, color: Colors.grey[400], size: 20),
        CustomSvgImage(assetName: assetPath),
        const SizedBox(width: 6),
        Text(count.toString(), style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ],
    );
  }
}
