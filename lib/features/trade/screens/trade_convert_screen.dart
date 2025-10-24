// lib/features/trade/screens/trade_convert_screen.dart
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
                const SizedBox(height: 24),

                // Wallet Balance Summary
                _buildWalletSummary(),

                const SizedBox(height: 24),

                _buildSwapContainer(context),
                const SizedBox(height: AppSizes.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!controller.validateTrade()) {
                        return;
                      }

                      // Show confirmation dialog
                      final bool? confirmed = await ConfirmOrderDialog.show(
                        context,
                        fromCoin: controller.fromCoin.value!,
                        toCoin: controller.toCoin.value!,
                        fromAmount: controller.fromAmount.value,
                        toAmount: controller.toAmount.value,
                      );

                      if (confirmed == true) {
                        // Execute the trade
                        final bool success = await controller.executeTrade();

                        // if (success) {
                        //   Get.to(
                        //     () => ConversionSuccessScreen(
                        //       fromCoin: controller.fromCoin.value!,
                        //       toCoin: controller.toCoin.value!,
                        //       fromAmount: controller.fromAmount.value,
                        //       toAmount: controller.toAmount.value,
                        //     ),
                        //   );
                        // } else {
                        //   ToastManager.show(
                        //     message: 'Trade failed. Please try again.',
                        //     backgroundColor: AppColors.red,
                        //   );
                        // }
                      }
                    },
                    child: const Text('Preview', style: TextStyle(color: AppColors.black)),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSummary() {
    return Obx(() {
      final WalletController walletController = Get.find<WalletController>();
      final double totalValue = walletController.totalValuation.value;
      final int coinCount = walletController.walletCoins.length;

      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Wallet Balance',
                  style: TextStyle(
                    color: AppColors.textGreyLight,
                    fontSize: AppSizes.fontSizeBodyS,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: Get.context!.txtTheme.displayMedium?.copyWith(fontSize: 26),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.greenContainer,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
              ),
              child: Text(
                '$coinCount Coins',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: AppSizes.fontSizeBodyS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
      child: Row(
        spacing: AppSizes.md,
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
          Expanded(
            flex: 1,
            child: Row(
              spacing: AppSizes.md,
              children: <Widget>[
                appbarIcon(assetPath: AppIcons.filter, onTap: () {}),
                appbarIcon(assetPath: AppIcons.assetHistory, onTap: () {}),
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
            padding: const EdgeInsets.symmetric(vertical: 5),
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
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwapContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('From', style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
              Obx(() {
                final double balance = controller.fromCoinBalance.value;
                final String coinSymbol = controller.fromCoin.value?.symbol ?? '';

                return Row(
                  children: <Widget>[
                    const Text(
                      'Available ',
                      style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                    ),
                    Text(
                      balance > 0 ? '${controller.formatCoinAmount(balance)} $coinSymbol' : '0.00',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: <Widget>[
              Obx(
                () => _buildTokenSelector(
                  context,
                  coin: controller.fromCoin.value,
                  token: controller.fromToken.value,
                  color: AppColors.green,
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
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Obx(
                      () => TextField(
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppColors.grey),
                          border: InputBorder.none,
                        ),
                        onChanged: controller.updateFromAmount,
                        controller: TextEditingController(text: controller.fromAmount.value),
                      ),
                    ),
                    const SizedBox(height: 4),
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
                              ' \$${usdValue.toStringAsFixed(2)}',
                              style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (controller.fromCoin.value != null) {
                              controller.setMaxAmount();
                            } else {
                              ToastManager.show(message: 'Please select a coin first');
                            }
                          },
                          child: const Text(
                            'Max',
                            style: TextStyle(
                              color: AppColors.yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('To', style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Obx(
                () => _buildTokenSelector(
                  context,
                  coin: controller.toCoin.value,
                  token: controller.toToken.value,
                  color: AppColors.redContainer,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Obx(() {
                      final String displayAmount =
                          controller.toAmount.value.isEmpty || controller.toAmount.value == '0'
                          ? '0.00'
                          : controller.toAmount.value;
                      return Text(
                        displayAmount,
                        style: TextStyle(
                          color: controller.toAmount.value == '0'
                              ? AppColors.grey.withOpacity(0.4)
                              : AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    Obx(() {
                      if (controller.toCoin.value != null &&
                          controller.toAmount.value.isNotEmpty &&
                          controller.toAmount.value != '0') {
                        final double amount = double.tryParse(controller.toAmount.value) ?? 0;
                        final double usdValue = amount * controller.toCoin.value!.price;
                        return Text(
                          ' \$${usdValue.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textGreyLight, fontSize: 12),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Show coin image if available, otherwise show colored circle
            if (coin != null)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: coin.thumb,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) => Container(
                      color: color,
                      child: Center(
                        child: Text(
                          token.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
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
                          token.substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    token.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Text(
              token,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
            // if (isFromWallet) ...<Widget>[
            //   const SizedBox(width: 4),
            //   Container(
            //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //     decoration: BoxDecoration(
            //       color: AppColors.greenContainer,
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: const Text(
            //       'Wallet',
            //       style: TextStyle(
            //         color: AppColors.green,
            //         fontSize: 10,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwapIconButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: controller.swapTokens,
        child: Stack(
          children: <Widget>[
            const Divider(),
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                    border: Border.all(color: AppColors.textGreyLight.withOpacity(0.4), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomSvgImage(assetName: AppIcons.exchange, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        child: CustomSvgImage(assetName: assetPath, color: AppColors.white, height: 20),
      ),
    );
  }
}
