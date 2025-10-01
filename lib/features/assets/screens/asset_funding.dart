import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';
import 'package:neonecy_test/features/assets/controllers/assets_controller.dart';
import 'package:neonecy_test/features/home/controllers/home_controller.dart';
import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart' show AppColors;
import '../../../core/design/app_icons.dart';
import '../../../core/design/app_images.dart';
import '../../../core/utils/device/device_utility.dart';
import '../../home/widgets/custom_refresher.dart';
import '../model/coin_model.dart';
import '../widgets/funding_card.dart';

class AssetFundingScreen extends GetView<AssetsController> {
  const AssetFundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return CustomGifRefreshWidget(
      onRefresh: () async {
        await controller.onRefresh();
      },

      gifAssetPath: AppImages.loader, // Your gif asset path
      refreshTriggerDistance: 80.0,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  spacing: 5,
                  children: <Widget>[
                    Text(
                      'Est.Total Value(USD) ',
                      style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.85)),
                    ),
                    CustomSvgImage(assetName: AppIcons.eye, height: 12),
                  ],
                ),
                Row(
                  spacing: AppSizes.md,
                  children: <Widget>[
                    clickableIcon(
                      icon: CustomSvgImage(assetName: AppIcons.assetHistory, height: 20),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            /// ========> The dollar amount and the add fund button  =======>
            Row(
              children: <Widget>[
                Obx(
                  () => Text(
                    '\$ ${homeController.balance.value}',
                    style: context.txtTheme.displayMedium?.copyWith(fontSize: 26),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'USD',
                  style: context.txtTheme.headlineMedium?.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const Icon(Icons.arrow_drop_down_sharp),
              ],
            ),
            const SizedBox(height: AppSizes.sm),

            /// ========> The PNL percentage =======>
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Today's PNL ", style: TextStyle(color: AppColors.white, fontSize: 11)),
                Text(
                  "+\$0.00146468 (+0.50%) ",
                  style: TextStyle(color: AppColors.greenAccent, fontSize: 11),
                ),
                Text(">", style: TextStyle(color: AppColors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            /// ==========> The three buttons ===>
            Row(
              spacing: 8,
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                    bgColor: AppColors.yellow,
                    textColor: AppColors.black,
                    labelText: 'Add Funds',
                    onTap: () async {},
                  ),
                ),
                Expanded(
                  child: AppButton(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),

                    bgColor: AppColors.iconBackgroundLight,
                    textColor: AppColors.textWhite,
                    labelText: 'Send',
                    onTap: () {},
                  ),
                ),
                Expanded(
                  child: AppButton(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),

                    bgColor: AppColors.iconBackgroundLight,
                    textColor: AppColors.textWhite,
                    labelText: 'Transfer',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(),

            /// ==========> Search and Tab bar =========>
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Balances', style: context.txtTheme.headlineMedium),
                const Icon(CupertinoIcons.search),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Obx(
              () => CheckboxListTile(
                activeColor: AppColors.yellow,
                checkColor: AppColors.primaryColor,
                title: Text('Hide assets <1 USD', style: context.txtTheme.bodyMedium),
                value: controller.lessThanDollarItems.value,
                onChanged: (bool? value) {
                  controller.toggleHideAssets();
                },
                controlAffinity: ListTileControlAffinity.leading,

                contentPadding: EdgeInsets.zero,

                dense: true,
              ),
            ),
            Obx(
              () => Visibility(
                replacement: const CustomLoading(),
                visible: controller.isLoadingCoin.value == false,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  itemCount: controller.coinItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final CoinItem coin = controller.coinItems[index];
                    return FundingCard(
                      cryptoName: coin.name,
                      cryptoSymbol: coin.symbol,
                      balance: '\$${coin.priceBtc.toStringAsFixed(10)}',
                      price: '\$${coin.price.toStringAsFixed(4)}',
                      pnl: '${coin.marketCap}',
                      percentageChange: '',
                      iconImage: coin.thumb,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Material clickableIcon({required Widget icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        splashColor: AppColors.primaryColor,
        onTap: () {
          DeviceUtility.hapticFeedback();
          onTap();
        },
        child: icon,
      ),
    );
  }
}
