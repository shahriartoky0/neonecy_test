import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_icons.dart';

import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/utils/device/device_utility.dart';

// ========== Controller (separate file recommended) ==========
class CryptoSwapController extends GetxController {
  final RxInt selectedOrderType = 0.obs;
  final RxString fromToken = 'PEPE'.obs;
  final RxString toToken = 'PLUME'.obs;
  final RxString fromAmount = '950'.obs;
  final RxString toAmount = '0.12'.obs;
  final RxString availableBalance = '20,000'.obs;
  final RxString maxFromRange = '9600000000'.obs;
  final RxString maxToRange = '1200000'.obs;

  void selectOrderType(int index) {
    selectedOrderType.value = index;
  }

  void swapTokens() {
    final String tempToken = fromToken.value;
    final String tempAmount = fromAmount.value;
    final String tempRange = maxFromRange.value;

    fromToken.value = toToken.value;
    fromAmount.value = toAmount.value;
    maxFromRange.value = maxToRange.value;

    toToken.value = tempToken;
    toAmount.value = tempAmount;
    maxToRange.value = tempRange;
  }

  void updateFromAmount(String value) {
    fromAmount.value = value;
    if (value.isNotEmpty) {
      final double amount = double.tryParse(value) ?? 0;
      const double rate = 0.000126;
      toAmount.value = (amount * rate).toStringAsFixed(8);
    }
  }

  void setMaxAmount() {
    fromAmount.value = availableBalance.value.replaceAll(',', '');
    updateFromAmount(fromAmount.value);
  }
}

// ========== Widget ==========
class TradeScreen extends GetView<CryptoSwapController> {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildOrderTypeSelector(),
            const SizedBox(height: 24),
            _buildSwapContainer(),
            SizedBox(height: AppSizes.lg),
            AppButton(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md, horizontal: AppSizes.sm),
              labelText: 'Preview',
              onTap: () {},
              bgColor: AppColors.yellow,
              textColor: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.history, color: Colors.white),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg)),
      child: Row(
        spacing: AppSizes.xl,
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
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwapContainer() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: <Widget>[_buildFromSection(), _buildSwapIconButton(), _buildToSection()],
      ),
    );
  }

  Widget _buildFromSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('From', style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
              Obx(
                () => Row(
                  children: <Widget>[
                    const Text(
                      'Available ',
                      style: TextStyle(color: AppColors.textWhite, fontSize: 14),
                    ),
                    Text(
                      '${controller.availableBalance.value} PEPE',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: <Widget>[
              Obx(() => _buildTokenSelector(controller.fromToken.value, AppColors.green)),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Obx(
                      () => Text(
                        '${controller.fromAmount.value} - ${controller.maxFromRange.value}',
                        style: TextStyle(
                          color: AppColors.grey.withValues(alpha: 0.4),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: controller.setMaxAmount,
                      child: const Text(
                        'Max',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildToSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('To', style: TextStyle(color: AppColors.textGreyLight, fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Obx(() => _buildTokenSelector(controller.toToken.value, const Color(0xFFE91E63))),
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Obx(
                    () => Text(
                      '${controller.toAmount.value} - ${controller.maxToRange.value}',
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.4),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTokenSelector(String token, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
        ],
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
              alignment: Alignment.center, // This will center the container
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
                    border: Border.all(color: const Color(0xFF3A4552), width: 2),
                  ),
                  child: const Icon(Icons.swap_vert, color: Colors.white, size: 20),
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
        },
        child: CustomSvgImage(assetName: assetPath, color: AppColors.white, height: 20),
      ),
    );
  }
}
