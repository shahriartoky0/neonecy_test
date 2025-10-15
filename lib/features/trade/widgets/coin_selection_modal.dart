// lib/features/assets/view/widgets/coin_selection_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../assets/model/coin_model.dart';
import '../controllers/coin_selection_controller.dart';

class CoinSelectionBottomSheet extends StatelessWidget {
  const CoinSelectionBottomSheet({super.key});

  static Future<CoinItem?> show(BuildContext context) {
    return showModalBottomSheet<CoinItem>(
      context: context,
      backgroundColor: AppColors.primaryColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXxl)),
      ),
      builder: (BuildContext context) => const CoinSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CoinSelectionController controller = Get.put(CoinSelectionController());

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXxl)),
          ),
          child: Column(
            children: <Widget>[
              // Header
              _buildHeader(controller),

              // Search Bar
              _buildSearchBar(controller),

              const SizedBox(height: AppSizes.sm),

              // Tabs
              _buildTabs(controller: controller),

              const SizedBox(height: AppSizes.md),

              // Coin List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CustomLoading());
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.red,
                            size: AppSizes.iconXxl,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: AppColors.textGreyLight),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.md),
                          ElevatedButton(
                            onPressed: controller.fetchCoins,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.filteredCoins.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.search_off,
                            color: AppColors.textGreyLight.withOpacity(0.5),
                            size: AppSizes.iconXxl,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'No coins found',
                            style: TextStyle(
                              color: AppColors.textGreyLight.withOpacity(0.7),
                              fontSize: AppSizes.fontSizeBodyM,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                    itemCount: controller.filteredCoins.length,
                    itemBuilder: (BuildContext context, int index) {
                      final CoinItem coin = controller.filteredCoins[index];
                      return _buildCoinItem(coin, controller);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(CoinSelectionController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: <Widget>[
          const Text(
            'From',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: AppSizes.fontSizeH3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            color: AppColors.textGreyLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(CoinSelectionController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        ),
        child: TextField(
          onChanged: controller.searchCoins,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: const TextStyle(color: AppColors.hintText),
            prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textGreyLight),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs({required CoinSelectionController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Obx(
          () => Row(
            children: <Widget>[
              topTabButton(
                label: 'Single Coin',
                isSelected: controller.isSingleCoinSelected(),
                onTap: () {
                  controller.selectTab(0);
                },
              ),
              const SizedBox(width: AppSizes.sm),
              topTabButton(
                label: 'Multi Coin',
                isSelected: controller.isMultipleCoinSelected(),
                onTap: () {
                  controller.selectTab(1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinItem(CoinItem coin, CoinSelectionController controller) {
    final bool isPositive = coin.percentChange24h >= 0;

    return InkWell(
      onTap: () => controller.selectCoin(coin),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.iconBackground.withOpacity(0.3), width: 0.5),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Coin Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                child: CachedNetworkImage(
                  imageUrl: coin.thumb,
                  placeholder: (BuildContext context, String url) => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child:  CustomLoading(),
                    ),
                  ),
                  errorWidget: (BuildContext context, String url, Object error) =>
                      const Icon(Icons.currency_bitcoin, color: AppColors.textGreyLight),
                ),
              ),
            ),

            const SizedBox(width: AppSizes.md),

            // Coin Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    coin.symbol,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppSizes.fontSizeBodyM,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.name,
                    style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: AppSizes.fontSizeBodyS,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _formatBalance(coin.price),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Text(
                      '\$${coin.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive ? AppColors.greenContainer : AppColors.redContainer,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${coin.percentChange24h.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositive ? AppColors.green : AppColors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Expanded topTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.iconBackgroundLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
              color: isSelected ? AppColors.textWhite : AppColors.textGreyLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Text(label),
          ),
        ),
      ),
    );
  }

  String _formatBalance(double balance) {
    if (balance >= 1) {
      return balance.toStringAsFixed(2);
    } else if (balance >= 0.01) {
      return balance.toStringAsFixed(4);
    } else if (balance >= 0.0001) {
      return balance.toStringAsFixed(6);
    } else {
      return balance.toStringAsExponential(2);
    }
  }
}
