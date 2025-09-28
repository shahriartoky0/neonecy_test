import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/network/network_response.dart';
import 'package:neonecy_test/core/utils/logger_utils.dart';
import 'package:neonecy_test/features/assets/controllers/assets_controller.dart';

import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart' show AppColors;
import '../../../core/design/app_icons.dart';
import '../../../core/utils/coin_gecko.dart';
import '../../../core/utils/device/device_utility.dart';
import '../widgets/crypto_card.dart';
import '../widgets/funding_card.dart';

class AssetFundingScreen extends GetView<AssetsController> {
  const AssetFundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  icon: CustomSvgImage(assetName: AppIcons.assetHistory, height: 24),
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
            Text(
              '\$0 297854454',
              style: context.txtTheme.displayMedium,
              overflow: TextOverflow.ellipsis,
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
            Text("Today's PNL "),
            Text("+\$0.00146468 (+0.50%) "),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                bgColor: AppColors.yellow,
                textColor: AppColors.black,
                labelText: 'Add Funds',
                onTap: () async {},
              ),
            ),
            Expanded(
              child: AppButton(
                padding: const EdgeInsets.symmetric(vertical: 12),

                bgColor: AppColors.iconBackgroundLight,
                textColor: AppColors.textWhite,
                labelText: 'Send',
                onTap: () {},
              ),
            ),
            Expanded(
              child: AppButton(
                padding: const EdgeInsets.symmetric(vertical: 12),

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
        SizedBox(height: AppSizes.sm),
        CheckboxListTile(
          title: Text('Hide assets <1 USD', style: context.txtTheme.bodyMedium),
          value: false,
          onChanged: (bool? value) {},
          controlAffinity: ListTileControlAffinity.leading,
          // To make it look like a checkbox.
          contentPadding: EdgeInsets.all(0),
          // Remove extra padding
          dense: true, // To make the checkbox smaller
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return const FundingCard(
                cryptoName: 'PEPE',
                cryptoSymbol: 'PEPE',
                balance: '20000',
                price: '\$0.2052',
                pnl: '\$0.004',
                percentageChange: '(+0.56%)',
                icon: '🐸',
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          ),
        ),
      ],
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
