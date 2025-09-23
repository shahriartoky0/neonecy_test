import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';

import '../../../core/utils/device/device_utility.dart';

class FutureRight extends StatelessWidget {
  const FutureRight({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, double>> data = <Map<String, double>>[
      <String, double>{'value': 104610.0, 'number': 0.001},
      <String, double>{'value': 104609.9, 'number': 0.001},
      <String, double>{'value': 104609.8, 'number': 0.002},
      <String, double>{'value': 104609.7, 'number': 0.002},
      <String, double>{'value': 104609.6, 'number': 0.413},
      // <String, double>{'value': 104609.4, 'number': 13.677},
      // <String, double>{'value': 104609.3, 'number': 5.080},
      // <String, double>{'value': 104609.2, 'number': 0.004},
      // <String, double>{'value': 104608.8, 'number': 0.001},
      // <String, double>{'value': 104608.4, 'number': 0.001},
      // <String, double>{'value': 104608.3, 'number': 0.002},
      // <String, double>{'value': 104608.0, 'number': 0.001},
      // <String, double>{'value': 104607.7, 'number': 0.002},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            clickableIcon(
              icon: CustomSvgImage(assetName: AppIcons.futureGift, height: 24),
              onTap: () {},
            ),

            clickableIcon(
              icon: CustomSvgImage(assetName: AppIcons.filter, height: 24),

              onTap: () {},
            ),
            clickableIcon(
              icon: CustomSvgImage(
                assetName: AppIcons.futurePlusMinus,
                height: 32,
                color: AppColors.textGreyLight,
              ),

              onTap: () {},
            ),

            clickableIcon(
              icon: CustomSvgImage(
                assetName: AppIcons.marketMenu,
                height: 4,
                color: AppColors.textGreyLight,
              ),

              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),

        const Text('Funding / Countdown', style: TextStyle(color: AppColors.textGreyLight)),
        const Text('0.0065%/03:37:37'),
        const SizedBox(height: AppSizes.sm),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Price', style: TextStyle(color: AppColors.textGreyLight)),
            Text('Amount', style: TextStyle(color: AppColors.textGreyLight)),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: <Widget>[
            Text('(USDT)', style: TextStyle(color: AppColors.textGreyLight)),
            Text('(BTC)', style: TextStyle(color: AppColors.textGreyLight)),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, double> item = data[index];

            return Container(
              color: AppColors.redContainer,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(item['value'].toString(), style: const TextStyle(color: AppColors.textRed, fontSize: 12)),
                  Text(item['number'].toString(), style: const TextStyle(color: AppColors.white,fontSize: 12)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.md),

        Column(
          children: <Widget>[
            Text(
              '10462.06',
              style: context.txtTheme.titleMedium?.copyWith(color: AppColors.greenAccent),
            ),
            const Text('10697.03', style: TextStyle(color: AppColors.textGreyLight)),
          ],
        ).centered,
        const SizedBox(height: AppSizes.sm),

        /// =========> Green View =====>
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            final Map<String, double> item = data[index];

            return Container(
              color: AppColors.greenContainer,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    item['value'].toString(),
                    style: const TextStyle(color: AppColors.greenAccent,fontSize: 12),
                  ),
                  Text(item['number'].toString(), style: const TextStyle(color: AppColors.white,fontSize: 12)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.md),

        /// ===========>  Dropdown plus the icon =====>
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 5,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('0.1', style: TextStyle(color: AppColors.textGreyLight)),
                  SizedBox(width: AppSizes.xl),
                  Icon(Icons.arrow_drop_down_outlined),
                ],
              ),
            ),
            CustomSvgImage(assetName: AppIcons.futurePage, height: 18),
          ],
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
        },
        child: icon,
      ),
    );
  }
}
