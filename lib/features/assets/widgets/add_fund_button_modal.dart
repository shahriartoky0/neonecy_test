// ═══════════════════════════════════════════════════════════════════════════════
// showAddFundModal — used by BOTH Funding and Overview pages
// ═══════════════════════════════════════════════════════════════════════════════
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';

import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_icons.dart';
import '../screens/deposit_select_coin_screen.dart';
import 'add_fund_modal_tile.dart';

void showAddFundModal(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: AppColors.bgColor,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
    ),
    builder: (BuildContext sheetCtx) {
      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusLg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              const SizedBox(height: AppSizes.md),
              Container(
                height: 4,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).centered,
              const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Text(
                  'Select Deposit Method',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── 1. Deposit Crypto ──────────────────────────────────────
              AddFundModalTile(
                onTap: () async {
                  Get.back(); // close sheet
                  await Future.delayed(Duration(milliseconds: 250));
                  Get.to(() => const DepositSelectCoinScreen(), transition: Transition.rightToLeft);
                },
                title: 'Deposit Crypto',
                subTitle: 'Deposit crypto from other exchanges/wallets',
                leadingWidget: const Icon(
                  CupertinoIcons.arrow_down_to_line_alt,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 10),

              // ── 2. Receive Via Binance Pay ─────────────────────────────
              AddFundModalTile(
                onTap: () {},
                title: 'Receive Via Binance Pay',
                subTitle: 'Receive crypto from other Binance users',
                leadingWidget: CustomSvgImage(assetName: AppIcons.appbarCoin, height: 20),
              ),

              const SizedBox(height: 10),

              // ── 3. P2P Trading ─────────────────────────────────────────
              AddFundModalTile(
                onTap: () {},
                title: 'P2P Trading',
                subTitle: 'Buy directly from users. Competitive pricing.',
                leadingWidget: CustomSvgImage(assetName: AppIcons.p2pTrading, height: 22),
              ),

              const SizedBox(height: 10),

              // ── 4. Deposit USD ─────────────────────────────────────────
              AddFundModalTile(
                onTap: () {},
                title: 'Deposit USD',
                subTitle: 'Deposit USD via SWIFT, card, Apple/Google Pay',
                leadingWidget: const Icon(Icons.wallet, color: AppColors.white),
              ),

              const SizedBox(height: AppSizes.xxxL),
            ],
          ),
        ),
      );
    },
  );
}
