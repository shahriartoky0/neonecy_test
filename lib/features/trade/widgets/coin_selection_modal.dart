// lib/features/trade/widgets/coin_selection_modal.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../assets/model/coin_model.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/models/coin_wallet_model.dart';
import '../controllers/coin_selection_controller.dart';

class CoinSelectionBottomSheet extends StatelessWidget {
  final bool fromWallet;

  const CoinSelectionBottomSheet({
    super.key,
    this.fromWallet = false,
  });

  static Future<CoinItem?> show(BuildContext context, {bool fromWallet = false}) {
    return showModalBottomSheet<CoinItem>(
      context: context,
      backgroundColor: AppColors.primaryColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXxl)),
      ),
      builder: (BuildContext context) => CoinSelectionBottomSheet(fromWallet: fromWallet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CoinSelectionController controller = Get.put(CoinSelectionController());
    final WalletController walletController = Get.find<WalletController>();

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:  AppSizes.lg),
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
              const SizedBox(height: AppSizes.md),
              // Search Bar
              _buildSearchBar(controller),

              const SizedBox(height: AppSizes.sm),



              // Coin List
              Expanded(
                child: Obx(() {
                  if (fromWallet) {
                    // Show wallet coins
                    final RxList<WalletCoinModel> walletCoins = walletController.walletCoins;

                    // Filter wallet coins based on search query
                    final List<WalletCoinModel> filteredWalletCoins = controller.searchQuery.value.isEmpty
                        ? walletCoins
                        : walletCoins.where((WalletCoinModel coin) {
                      return coin.coinDetails.name.toLowerCase().contains(
                          controller.searchQuery.value.toLowerCase()) ||
                          coin.coinDetails.symbol.toLowerCase().contains(
                              controller.searchQuery.value.toLowerCase());
                    }).toList();

                    if (filteredWalletCoins.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.textGreyLight.withOpacity(0.5),
                              size: AppSizes.iconXxl,
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              controller.searchQuery.value.isEmpty
                                  ? 'No coins in wallet'
                                  : 'No matching coins in wallet',
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
                      itemCount: filteredWalletCoins.length,
                      itemBuilder: (BuildContext context, int index) {
                        final WalletCoinModel walletCoin = filteredWalletCoins[index];
                        return _buildWalletCoinItem(walletCoin, controller);
                      },
                    );
                  }

                  // Show market coins
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

                      // Check if this coin is in wallet
                      final bool isInWallet = walletController.walletCoins.any(
                              (WalletCoinModel walletCoin) => walletCoin.coinDetails.symbol == coin.symbol
                      );

                      return _buildCoinItem(coin, controller, isInWallet: isInWallet);
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
          Text(
            fromWallet ? 'From' : 'Select Coin',
            style: const TextStyle(
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
         child: TextFormField(
          onChanged: controller.searchCoins,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: const TextStyle(color: AppColors.hintText,fontSize: 12),
            prefixIcon: const Icon(Icons.search, color: AppColors.textGreyLight, size: 16,),
            suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textGreyLight),
                onPressed: controller.clearSearch,
              )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding:   EdgeInsets.zero,
          ),
        ),
      ),
    );
  }


  Widget _buildWalletCoinItem(WalletCoinModel walletCoin, CoinSelectionController controller) {
    final CoinItem coin = walletCoin.coinDetails;
    final double balance = walletCoin.quantity;
    final double value = balance * coin.price;

    return InkWell(
      onTap: () => controller.selectCoin(coin),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.iconBackground.withOpacity(0.3),
              width: 0.5,
            ),
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
                      child: CustomLoading(),
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
                  Row(
                    children: <Widget>[
                      Text(
                        coin.symbol,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: AppSizes.fontSizeBodyM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xs),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.greenContainer,
                      //     borderRadius: BorderRadius.circular(4),
                      //   ),
                      //   child: const Text(
                      //     'In Wallet',
                      //     style: TextStyle(
                      //       color: AppColors.green,
                      //       fontSize: 10,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                    ],
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

            // Balance and Value
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _formatBalance(balance),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '≈ \$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: AppSizes.fontSizeBodyS,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinItem(CoinItem coin, CoinSelectionController controller, {bool isInWallet = false}) {
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
                      child: CustomLoading(),
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
                  Row(
                    children: <Widget>[
                      Text(
                        coin.symbol,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: AppSizes.fontSizeBodyM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isInWallet) ...<Widget>[
                        const SizedBox(width: AppSizes.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.greenContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.green.withOpacity(0.5),
                              width: 0.5,
                            ),
                          ),
                          child: const Text(
                            'Owned',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
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
                  '\$${_formatPrice(coin.price)}',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive ? AppColors.greenContainer : AppColors.redContainer,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isPositive ? AppColors.green : AppColors.red,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${isPositive ? '+' : ''}${coin.percentChange24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: isPositive ? AppColors.green : AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
          padding: EdgeInsets.symmetric(vertical: 6),
          margin: EdgeInsets.symmetric(horizontal: AppSizes.sm),
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
            child: Text(label,style: TextStyle(fontSize: 12),),
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

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(6);
    } else {
      return price.toStringAsFixed(8);
    }
  }

}