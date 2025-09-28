import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import '../controllers/crypto_market_controller.dart';
import '../model/crypto_data_model.dart';

class CryptoMarketWidget extends GetView<CryptoMarketController> {
  const CryptoMarketWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Column(
        children: <Widget>[_buildTabBar(), _buildCategoryBar(), _buildHeader(), _buildCryptoList()],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: controller.tabs.asMap().entries.map((MapEntry<int, String> entry) {
            final int index = entry.key;
            final String tab = entry.value;
            final bool isSelected = controller.selectedTab.value == index;

            return GestureDetector(
              onTap: () => controller.selectTab(index),
              child: Text(
                tab,

                style: Get.context!.txtTheme.headlineMedium?.copyWith(
                  fontSize: isSelected ? 18 : 16,
                  color: isSelected ? AppColors.textWhite : AppColors.textGreyLight,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Obx(
        () => Row(
          children: controller.categories.asMap().entries.map((MapEntry<int, String> entry) {
            final int index = entry.key;
            final String category = entry.value;
            final bool isSelected = controller.selectedCategory.value == index;

            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.textGreyLight,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: const Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text('Name', style: TextStyle(color: AppColors.textGreyLight)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Last Price',
              style: TextStyle(color: AppColors.textGreyLight),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '24h Chg%',
              style: TextStyle(color: AppColors.textGreyLight),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList() {
    return Obx(
          ()   {
        // if (controller.isLoading.value) {
        //   return const SizedBox(
        //     height: 200,
        //     child: Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           CustomLoading(),
        //           SizedBox(height: 16),
        //           Text(
        //             'Loading trending cryptocurrencies...',
        //             style: TextStyle(color: AppColors.textGreyLight),
        //           ),
        //         ],
        //       ),
        //     ),
        //  );
        // }

        if (controller.cryptoList.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'No data available',
                style: TextStyle(color: AppColors.textGreyLight),
              ),
            ),
          );
        }

        return Column(
          children: controller.cryptoList
              .map((CryptoData crypto) => _buildCryptoItem(crypto))
              .toList(),
        );
      },
    );
  }

// Updated crypto item with additional data
  Widget _buildCryptoItem(CryptoData crypto) {
    final Color changeColor = crypto.changePercent >= 0 ? AppColors.green : AppColors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.sm),
      child: Row(
        children: <Widget>[
          // Symbol and name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crypto.symbol,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (crypto.name != null)
                  Text(
                    crypto.name!,
                    style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Price and relevant subtext
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  crypto.formattedPrice,
                  style: const TextStyle(color: AppColors.white),
                  textAlign: TextAlign.right,
                ),
                if (crypto.subText != null)
                  Text(
                    crypto.subText!,
                    style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.right,
                  ),
              ],
            ),
          ),

          // Change percentage
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  crypto.formattedChangePercent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
}
