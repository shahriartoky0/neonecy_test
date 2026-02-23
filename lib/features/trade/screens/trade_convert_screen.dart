// lib/features/trade/screens/trade_convert_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
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
import '../widgets/conversion_details_screen.dart';

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
                _buildSwapContainer(context),
                const SizedBox(height: 20),
                _buildPreviewButton(),
                SizedBox(height: context.screenHeight * 0.3),
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
            flex: 4,
            child: Row(
              children: <Widget>[
                _buildOrderTypeTab('Instant', 0),
                _buildOrderTypeTab('Recurring', 1),
                _buildOrderTypeTab('Limit', 2),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.lg),
          Row(
            children: <Widget>[
              appbarIcon(assetPath: AppIcons.filter, onTap: () {}),
              const SizedBox(width: AppSizes.sm),
              appbarIcon(assetPath: AppIcons.assetHistory, onTap: () {}),

            ],
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
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5), fontSize: 18),
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Obx(() {
                if (controller.fromCoin.value != null &&
                    controller.fromAmount.value.isNotEmpty &&
                    controller.fromAmount.value != '0') {
                  final double amount = double.tryParse(controller.fromAmount.value) ?? 0;
                  final double usdValue = amount * controller.fromCoin.value!.price;
                  return Text(
                    '~ ${controller.formatDisplayNumber(usdValue)}',
                    style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  );
                }
                return const SizedBox.shrink();
              }),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (controller.fromCoin.value != null) {
                    controller.setMaxAmount();
                  } else {
                    ToastManager.show(message: 'Please select a coin first');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: const Text(
                    'Max',
                    style: TextStyle(
                      color: AppColors.yellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Obx(() {
                      final String displayAmount =
                      controller.toAmount.value.isEmpty || controller.toAmount.value == '0'
                          ? '0'
                          : controller.toAmount.value;
                      return Text(
                        displayAmount,
                        style: TextStyle(
                          color:
                          controller.toAmount.value == '0' || controller.toAmount.value.isEmpty
                              ? AppColors.grey.withOpacity(0.5)
                              : AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (controller.toCoin.value != null &&
                          controller.toAmount.value.isNotEmpty &&
                          controller.toAmount.value != '0') {
                        final double amount = double.tryParse(controller.toAmount.value) ?? 0;
                        final double usdValue = amount * controller.toCoin.value!.price;
                        return Text(
                          '~ ${controller.formatDisplayNumber(usdValue)}',
                          style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
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
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textGreyLight.withOpacity(0.3), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: CustomSvgImage(assetName: AppIcons.exchange, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButton() {
    return Obx(() {
      final bool isEnabled = controller.canTrade;

      return Container(
        decoration: BoxDecoration(
          boxShadow: isEnabled ? <BoxShadow>[
            BoxShadow(
              color: AppColors.yellow.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isEnabled ? () async {
              if (!controller.validateTrade()) {
                return;
              }

              final bool? confirmed = await ConfirmOrderDialog.show(
                Get.context!,
                fromCoin: controller.fromCoin.value!,
                toCoin: controller.toCoin.value!,
                fromAmount: controller.fromAmount.value,
                toAmount: controller.toAmount.value,
              );

              if (confirmed == true) {
                await controller.executeTrade();
              }
            } :(){
              controller.validateTrade();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? AppColors.yellow
                  : AppColors.yellow.withOpacity(0.4),
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
                fontWeight: FontWeight.w600,
              ),
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