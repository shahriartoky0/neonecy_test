import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';

class FutureLeft extends StatelessWidget {
  const FutureLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('BTCUSDT ', style: context.txtTheme.headlineMedium),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                color: AppColors.iconBackground,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: const Text('Perp'),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_sharp),
          ],
        ),
        const Text('-0.99%', style: TextStyle(color: AppColors.textRed)),
        const SizedBox(height: AppSizes.md),
        Row(
          spacing: AppSizes.sm,
          children: <Widget>[
            Expanded(
              child: topButton(label: 'Cross', onTap: () {}),
            ),
            Expanded(
              child: topButton(label: '20x', onTap: () {}),
            ),
            Expanded(
              child: topButton(label: 'S', onTap: () {}),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Avbl', style: TextStyle(color: AppColors.textGreyLight)),
            Row(
              children: <Widget>[
                const Text('--', style: TextStyle(color: AppColors.textGreyLight)),
                Icon(Icons.repeat, color: AppColors.yellow.withValues(alpha: 0.7)),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        /// ===> limit container ===========>
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Icon(CupertinoIcons.info_circle_fill),
              Text('Limit', style: context.txtTheme.labelMedium),
              const Icon(Icons.arrow_drop_down_sharp),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.sm),

        /// ===> price container ===========>
        Row(
          spacing: 8,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              child: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Icon(CupertinoIcons.minus, size: 12,),
                  Column(
                    spacing: 5,
                    children: <Widget>[
                      const Text(
                        'Price (USTD)',
                        style: TextStyle(color: AppColors.textGreyLight, fontSize: 12),
                      ),
                      Text('104632.01', style: context.txtTheme.labelMedium),
                    ],
                  ),
                  const Icon(CupertinoIcons.plus, size: 12,),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 12),
              child: Text('BBO', style: context.txtTheme.labelMedium),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        /// ===> Amount container ===========>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
          ),
          child: Row(
            spacing: 5,
            children: <Widget>[
              const Icon(CupertinoIcons.minus, size: 12,),
              Text('Amount', style: context.txtTheme.labelMedium),
              const Icon(CupertinoIcons.plus, size: 12,),
              Text('| ', style: context.txtTheme.labelMedium),
              Text('BTC', style: context.txtTheme.labelMedium),
              const Icon(Icons.arrow_drop_down_sharp),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        CustomSvgImage(assetName: AppIcons.futureDivider),
        const SizedBox(height: AppSizes.md),
        Row(
          children: <Widget>[
            Radio<String>(value: 'TP/SL', groupValue: 'Tp/SL', onChanged: (String? value) {}),
            const Text('TP/SL'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Radio<String>(
                  value: 'Reduce Only',
                  groupValue: 'Reduce Only',
                  onChanged: (String? value) {},
                ),
                const Text('Reduce Only'),
              ],
            ),
            const Row(children: <Widget>[Text('GTC'), Icon(Icons.arrow_drop_down_sharp)]),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        /// ============>   Max Cost ===>
        maxRow(context, label: 'Max', value: '0.000BTC'),
        maxRow(context, label: 'Cost', value: '0.000BTC'),
        const SizedBox(height: AppSizes.sm),

        /// ===> Button =>
        AppButton(
          labelText: 'Buy/Long',
          onTap: () {},
          bgColor: AppColors.greenAccent,
          padding: const EdgeInsets.symmetric(vertical: 6),
        ),
        const SizedBox(height: AppSizes.md),
        maxRow(context, label: 'Max', value: '0.000BTC'),
        maxRow(context, label: 'Cost', value: '0.000BTC'),
        const SizedBox(height: AppSizes.sm),

        /// ===> Button =>
        AppButton(
          labelText: 'Sell/short',
          onTap: () {},
          bgColor: AppColors.red,
          padding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ],
    );
  }

  Row maxRow(BuildContext context, {required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: context.txtTheme.headlineMedium?.copyWith(fontSize: 12)),
        Text(value),
      ],
    );
  }

  InkWell topButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      splashColor: AppColors.iconBackgroundLight,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
          border: Border.all(color: AppColors.textGreyLight.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
        ).centered,
      ),
    );
  }
}
