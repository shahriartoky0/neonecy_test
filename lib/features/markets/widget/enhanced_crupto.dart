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
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            ),
            child: Column(
              children: <Widget>[_buildTabBar(), _buildCryptoTable(), _buildLoadingIndicator()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: controller.tabs.asMap().entries.map((MapEntry<int, String> entry) {
              final int index = entry.key;
              final String tab = entry.value;
              final bool isSelected = controller.selectedTab.value == index;

              return GestureDetector(
                onTap: () => controller.selectTab(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 24),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.textWhite : AppColors.textGreyLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoTable() {
    return Obx(
      () => Column(
        children: <Widget>[
          _buildTableHeader(),
          ...controller.cryptoList.map((EnhancedCryptoData crypto) => _buildCryptoRow(crypto)),
          if (controller.cryptoList.isEmpty && !controller.isLoading.value) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              onTap: () => controller.sortBy('symbol'),
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
              onTap: () => controller.sortBy('price'),
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
              onTap: () => controller.sortBy('change'),
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
      if (controller.sortBy.value != field) {
        return const SizedBox.shrink();
      }

      return Icon(
        controller.isAscending.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: AppColors.textWhite,
        size: 16,
      );
    });
  }

  Widget _buildCryptoRow(EnhancedCryptoData crypto) {
    final Color changeColor = crypto.changePercent >= 0 ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textGreyLight.withValues(alpha: 0.1), width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Name and Volume section
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 8),
                Expanded(
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
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/USDT',
                            style: TextStyle(
                              color: AppColors.textGreyLight.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              ],
            ),
          ),

          // Last Price section
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
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  "\$${crypto.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: AppColors.textGreyLight.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 24h Change section
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  crypto.changePercentFormatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: <Widget>[
          Icon(Icons.search_off, size: 48, color: AppColors.textGreyLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No cryptocurrencies found',
            style: TextStyle(color: AppColors.textGreyLight.withValues(alpha: 0.7), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!controller.isLoading.value) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        child: const CustomLoading(),
      );
    });
  }
}
