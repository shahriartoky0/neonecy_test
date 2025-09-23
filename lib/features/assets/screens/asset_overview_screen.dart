import 'package:flutter/material.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';

import '../../../core/common/widgets/app_button.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart' show AppColors;
import '../../../core/design/app_icons.dart';
import '../../../core/utils/device/device_utility.dart';
import '../widgets/crypto_card.dart';
import '../widgets/tab_row.dart';

class AssetOverviewScreen extends StatelessWidget {
  const AssetOverviewScreen({super.key});

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
                  icon: CustomSvgImage(assetName: AppIcons.assetsGraph, height: 24),
                  onTap: () {},
                ),
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
            Text("+\$0.00146468 (+0.50%) ", style: TextStyle(color: AppColors.green)),
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
                onTap: () {},
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
        TabRow(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            itemCount: 5,
            itemBuilder: (BuildContext context, int index) {
              return const CryptoCard(
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
              return const Column(
                children: [
                  SizedBox(height: AppSizes.sm),
                  Divider(),
                ],
              );
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
