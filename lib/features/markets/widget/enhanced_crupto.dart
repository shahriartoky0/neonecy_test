import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import '../../../core/utils/custom_loader.dart';
import '../controllers/enhanced_market_controller.dart';
import '../model/enhanced_crypto_data_model.dart';

class EnhancedCryptoMarketWidget extends GetView<EnhancedCryptoMarketController> {
  const EnhancedCryptoMarketWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSpotHeader(),
          _buildTableHeader(),
          _buildCryptoTable(),
          _buildLoadingIndicator(),
          const SizedBox(height: AppSizes.xxxL),
        ],
      ),
    );
  }

  Widget _buildSpotHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 10),
      child: Row(
        children: <Widget>[
          const Text(
            'Spot',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(Icons.grid_view_rounded, color: AppColors.textGreyLight, size: 20),
          const SizedBox(width: AppSizes.md),
          const Icon(Icons.edit_outlined, color: AppColors.textGreyLight, size: 20),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textGreyLight.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => controller.changeSortField('symbol'),
              child: Row(
                children: <Widget>[
                  const Text(
                    'Name / Vol',
                    style: TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildSortIcon('symbol'),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => controller.changeSortField('price'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Last Price',
                    style: TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildSortIcon('price'),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => controller.changeSortField('change'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '24h Chg%',
                    style: TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildSortIcon('change'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortIcon(String field) {
    return Obx(() {
      if (controller.sortBy.value != field) return const SizedBox.shrink();
      return Icon(
        controller.isAscending.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: AppColors.textWhite,
        size: 16,
      );
    });
  }

  Widget _buildCryptoTable() {
    return Obx(() {
      if (controller.cryptoList.isEmpty && !controller.isLoading.value) {
        return _buildEmptyState();
      }
      return Column(
        children: controller.cryptoList
            .map((EnhancedCryptoData crypto) => _buildCryptoRow(crypto))
            .toList(),
      );
    });
  }

  Widget _buildCryptoRow(EnhancedCryptoData crypto) {
    final Color changeColor = crypto.changePercent >= 0 ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textGreyLight.withValues(alpha: 0.1), width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          // ── Coin logo ──────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: crypto.logoUrl,
              width: 36,
              height: 36,
              placeholder: (BuildContext ctx, String url) => _coinPlaceholder(crypto.symbol),
              errorWidget: (BuildContext ctx, String url, Object err) =>
                  _coinPlaceholder(crypto.symbol),
            ),
          ),
          const SizedBox(width: 10),

          // ── Symbol / Volume ────────────────────────────────────
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      crypto.symbol,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '/USDT',
                      style: TextStyle(
                        color: AppColors.textGreyLight.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackgroundLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        crypto.leverage,
                        style: const TextStyle(color: AppColors.hintText, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  crypto.formattedVolume,
                  style: TextStyle(
                    color: AppColors.textGreyLight.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Price ──────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  crypto.formattedPrice,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${crypto.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textGreyLight.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── % Change badge ─────────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  crypto.changePercentFormatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coinPlaceholder(String symbol) {
    const List<Color> colors = <Color>[
      Color(0xFFF3BA2F), // yellow/gold
      Color(0xFF627EEA), // blue/indigo
      Color(0xFF9945FF), // purple
      Color(0xFF24A584), // green
      Color(0xFFE84142), // red
      Color(0xFF0033AD), // deep blue
    ];
    final int colorIndex = symbol.isNotEmpty ? symbol.codeUnitAt(0) % colors.length : 0;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: <Widget>[
          Icon(Icons.search_off, size: 48, color: AppColors.textGreyLight.withValues(alpha: 0.5)),
          const SizedBox(height: AppSizes.md),
          Text(
            'No cryptocurrencies found',
            style: TextStyle(
              color: AppColors.textGreyLight.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();
      return const Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: CustomLoading(),
      );
    });
  }
}
