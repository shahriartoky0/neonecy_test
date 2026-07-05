// lib/features/trade/screens/trade_convert_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/features/home/widgets/custom_refresher.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';
import '../../../core/design/app_images.dart';
import '../../../core/utils/device/device_utility.dart';
import '../../assets/model/coin_model.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../controllers/trade_controller.dart';
import '../widgets/coin_selection_modal.dart';
import '../widgets/confirm_order_modal.dart';
import '../widgets/trade_order_views.dart';
import '../widgets/trade_preview_loader.dart';

class TradeConvertScreen extends GetView<TradeController> {
  const TradeConvertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TradeController controller = Get.put(TradeController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.screenHorizontal),
        child: CustomGifRefreshWidget(
          onRefresh: () async {
            await Get.find<WalletController>().fetchWalletCoins();
          },
          gifAssetPath: AppImages.loader,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildOrderTypeSelector(),
                const SizedBox(height: 20),
                Obx(() {
                  switch (controller.selectedOrderType.value) {
                    case 1:
                      return const RecurringOrderView();
                    case 2:
                      return const LimitOrderView();
                    default:
                      return Column(
                        children: <Widget>[
                          _buildSwapContainer(context),
                          const SizedBox(height: 16),
                          _buildRateLine(),
                          const SizedBox(height: 16),
                          _buildPreviewButton(),
                          SizedBox(height: context.screenHeight * 0.3),
                        ],
                      );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                _buildOrderTypeTab('Instant', 0),
                _buildOrderTypeTab('Recurring', 1),
                _buildOrderTypeTab('Limit', 2),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RotatedBox(
                  quarterTurns: 3,
                  child: CustomSvgImage(
                    assetName: AppIcons.sliderFilter,
                    color: AppColors.white,
                    height: 30,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                appbarIcon(
                  assetPath: AppIcons.assetHistory,
                  onTap: () => Get.toNamed(AppRoutes.historyScreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectOrderType(index),
        child: Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            decoration: BoxDecoration(
              color: controller.selectedOrderType.value == index
                  ? AppColors.iconBackground
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: controller.selectedOrderType.value == index
                    ? AppColors.white
                    : AppColors.textGreyLight,
                fontWeight: controller.selectedOrderType.value == index
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwapContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: <Widget>[
          _buildFromSection(context),
          _buildSwapIconButton(),
          _buildToSection(context),
        ],
      ),
    );
  }

  Widget _buildFromSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'From',
                style: TextStyle(
                  color: AppColors.textGreyLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Obx(() {
                final double balance = controller.fromCoinBalance.value;
                final String coinSymbol = controller.fromCoin.value?.symbol ?? '';

                return Row(
                  children: <Widget>[
                    CustomSvgImage(
                      assetName: AppIcons.walletIcon,
                      color: AppColors.white.withValues(alpha: 1),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Available ',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                        decorationColor: AppColors.textWhite.withOpacity(0.7),
                        decorationThickness: 1,
                      ),
                    ),
                    if (balance > 0 && coinSymbol.isNotEmpty) ...<Widget>[
                      Text(
                        controller.formatCoinAmount(balance),
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        coinSymbol,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      // Coin icon
                      if (controller.fromCoin.value?.thumb != null)
                        const Icon(
                          CupertinoIcons.add_circled_solid,
                          color: AppColors.yellow,
                          size: 18,
                        )
                      else
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monetization_on,
                            size: 10,
                            color: AppColors.black,
                          ),
                        ),
                    ] else
                      const Text(
                        '0.00',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                      ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Obx(
                () => _buildTokenSelector(
                  context,
                  coin: controller.fromCoin.value,
                  token: controller.fromToken.value,
                  color: AppColors.iconBackgroundLight,
                  isFromWallet: true,
                  onTap: () async {
                    final CoinItem? selectedCoin = await CoinSelectionBottomSheet.show(
                      context,
                      fromWallet: true,
                    );
                    if (selectedCoin != null) {
                      controller.selectFromCoin(selectedCoin);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.fromAmountController,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: AppColors.grey.withValues(alpha: 0.5),
                      fontSize: 21,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  onChanged: controller.updateFromAmount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Obx(() {
                final bool hasCoin = controller.fromCoin.value != null;
                return GestureDetector(
                  onTap: hasCoin ? controller.setMaxAmount : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Max',
                      style: TextStyle(
                        color: hasCoin
                            ? AppColors.yellow
                            : AppColors.textGreyLight.withValues(alpha: 0.35),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'To',
            style: TextStyle(
              color: AppColors.textGreyLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Obx(
                () => _buildTokenSelector(
                  context,
                  coin: controller.toCoin.value,
                  token: controller.toToken.value,
                  color: AppColors.iconBackgroundLight,
                  onTap: () async {
                    final CoinItem? selectedCoin = await CoinSelectionBottomSheet.show(
                      context,
                      fromWallet: false,
                    );
                    if (selectedCoin != null) {
                      controller.selectToCoin(selectedCoin);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final String displayAmount =
                      controller.toAmount.value.isEmpty || controller.toAmount.value == '0'
                      ? '0'
                      : controller.toAmount.value;
                  return Text(
                    displayAmount,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: controller.toAmount.value == '0' || controller.toAmount.value.isEmpty
                          ? AppColors.grey.withValues(alpha: 0.5)
                          : AppColors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenSelector(
    BuildContext context, {
    required CoinItem? coin,
    required String token,
    required Color color,
    bool isFromWallet = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (coin != null)
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: coin.thumb,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) => Container(
                      color: color,
                      child: Center(
                        child: Text(
                          token.isNotEmpty ? token.substring(0, 1) : '',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (BuildContext context, String url, Object error) => Container(
                      color: color,
                      child: Center(
                        child: Text(
                          token.isNotEmpty ? token.substring(0, 1) : '',
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    token.isNotEmpty && token != 'Select a Coin' ? token.substring(0, 1) : '',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              token == 'Select a Coin' ? '-- ' : token,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textWhite, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapIconButton() {
    return Container(
      margin: EdgeInsets.zero,
      child: GestureDetector(
        onTap: controller.swapTokens,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Divider(color: AppColors.textGreyLight.withValues(alpha: 0.5), thickness: 0.5),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textGreyLight.withOpacity(0.3), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: CustomSvgImage(assetName: AppIcons.exchange, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateLine() {
    return Obx(() {
      final double from = double.tryParse(controller.fromAmount.value) ?? 0;
      final double to = double.tryParse(controller.toAmount.value) ?? 0;
      final CoinItem? fromCoin = controller.fromCoin.value;
      final CoinItem? toCoin = controller.toCoin.value;

      if (from <= 0 || to <= 0 || fromCoin == null || toCoin == null) {
        return const SizedBox.shrink();
      }

      final double rate = from / to;
      final String rateStr = rate >= 1 ? rate.toStringAsFixed(6) : rate.toStringAsFixed(8);

      return Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '1 ${toCoin.symbol} = $rateStr ${fromCoin.symbol}',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
          Obx(() {
            if (!controller.showRateSpinner.value) return const SizedBox.shrink();
            return SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppColors.yellow,
                strokeWidth: 2,
                backgroundColor: AppColors.yellow.withValues(alpha: 0.5),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildPreviewButton() {
    return Obx(() {
      final bool isEnabled = controller.canTrade;

      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () async {
                  if (!controller.validateTrade()) {
                    return;
                  }

                  await TradePreviewLoader.show(Get.context!);

                  await ConfirmOrderDialog.show(
                    Get.context!,
                    fromCoin: controller.fromCoin.value!,
                    toCoin: controller.toCoin.value!,
                    fromAmount: controller.fromAmount.value,
                    toAmount: controller.toAmount.value,
                    onConfirm: controller.executeTrade,
                  );
                }
              : () {
                  controller.validateTrade();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? AppColors.yellow : AppColors.yellow.withOpacity(0.4),
            foregroundColor: AppColors.black,
            disabledBackgroundColor: AppColors.yellow.withOpacity(0.4),
            disabledForegroundColor: AppColors.textGreyLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            'Preview',
            style: TextStyle(
              color: isEnabled ? AppColors.black : AppColors.textGreyLight,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Material appbarIcon({required String assetPath, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        splashColor: AppColors.primaryColor,
        onTap: () {
          DeviceUtility.hapticFeedback();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomSvgImage(assetName: assetPath, color: AppColors.white, height: 18),
        ),
      ),
    );
  }
}
