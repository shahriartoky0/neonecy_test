import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import '../../../core/utils/custom_loader.dart';
import '../../assets/model/coin_model.dart' show CoinItem;
import '../../trade/controllers/coin_selection_controller.dart';
import '../controllers/settings_controller.dart';

class EditCoins extends GetView<SettingsController> {
  const EditCoins({super.key});

  @override
  Widget build(BuildContext context) {
    final CoinSelectionController controller = Get.put(CoinSelectionController());
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.primaryColor,

        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.white),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: AppSizes.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSizes.md,
          children: <Widget>[
            _buildSearchBar(controller), // Coin List
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CustomLoading());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.error_outline, color: AppColors.red, size: AppSizes.iconXxl),
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
                        color: AppColors.textGreyLight.withValues(alpha: 0.5),
                        size: AppSizes.iconXxl,
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'No coins found',
                        style: TextStyle(
                          color: AppColors.textGreyLight.withValues(alpha: 0.7),
                          fontSize: AppSizes.fontSizeBodyM,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                itemCount: controller.filteredCoins.length,
                itemBuilder: (BuildContext context, int index) {
                  final CoinItem coin = controller.filteredCoins[index];
                  return _buildCoinItem(coin, controller);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinItem(CoinItem coin, CoinSelectionController controller) {
    final bool isPositive = coin.percentChange24h >= 0;

    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.changeAddress, arguments: coin);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.iconBackground.withValues(alpha: 0.3), width: 0.5),
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
                  placeholder: (BuildContext context, String url) =>
                      const Center(child: SizedBox(width: 20, height: 20, child: CustomLoading())),
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

            const Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
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
}
