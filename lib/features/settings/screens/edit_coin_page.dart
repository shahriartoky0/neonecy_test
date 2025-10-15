// lib/features/assets/views/coin_amount_list_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import '../../../core/utils/custom_loader.dart';
import '../../assets/model/coin_model.dart' show CoinItem;
 import '../controllers/editable_coins_controller.dart';

class CoinAmountListPage extends GetView<CoinAmountController> {
  const CoinAmountListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CoinAmountController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.primaryColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.white),
        ),
        title: const Text(
          'Coin amount',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: AppSizes.fontSizeH3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.saveAllAmounts(),
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.yellow,
                fontSize: AppSizes.fontSizeBodyM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CustomLoading());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                  onPressed: controller.loadCoinsFromMarket,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.coins.isEmpty) {
          return const Center(
            child: Text(
              'No coins available',
              style: TextStyle(color: AppColors.textGreyLight),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.screenHorizontal),
          itemCount: controller.coins.length,
          itemBuilder: (context, index) {
            final coin = controller.coins[index];
            return _buildCoinItem(coin, context);
          },
        );
      }),
    );
  }

  Widget _buildCoinItem(CoinItem coin, BuildContext context) {
    final TextEditingController textController = TextEditingController(
      text: controller.getSavedAmount(coin.id) ?? '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      ),
      child: Row(
        children: [
          // Coin Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              child: CachedNetworkImage(
                imageUrl: coin.thumb,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomLoading(),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.currency_bitcoin,
                  color: AppColors.textGreyLight,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.md),

          // Coin Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

          const SizedBox(width: AppSizes.sm),

          // Editable Amount Field
          SizedBox(
            width: 100,
            child: TextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: AppSizes.fontSizeBodyL,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: AppColors.textGreyLight.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                  vertical: AppSizes.xs,
                ),
              ),
              onChanged: (value) {
                controller.updateAmount(coin.id, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}