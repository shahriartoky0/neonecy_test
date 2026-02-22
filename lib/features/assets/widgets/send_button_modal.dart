// lib/features/assets/widgets/send_button_modal.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';

 import '../screens/withdraw_select_coin.dart';
import 'add_fund_modal_tile.dart';

void sendButtonModal(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: AppColors.bgColor,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusLg)),
    ),
    builder: (BuildContext sheetCtx) {
      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.borderRadiusLg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: AppSizes.md),

              // Handle bar
              Container(
                height: 4,
                width: 70,
                decoration: BoxDecoration(
                  color: AppColors.iconBackgroundLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: Text(
                  'Select Withdraw Method',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),

              // ── 1. Send to Binance Users ─────────────────────────────
              AddFundModalTile(
                onTap: () {},
                title: 'Send to Binance Users',
                subTitle:
                'Binance internal transfer, send via Email/Phone/ID',
                leadingWidget: CustomSvgImage(
                    assetName: AppIcons.appbarCoin, height: 20),
              ),

              const SizedBox(height: 10),

              // ── 2. Withdraw Crypto ────────────────────────────────────
              AddFundModalTile(
                onTap: () {
                  Get.back(); // close sheet
                  Get.to(
                        () => const WithdrawSelectCoinScreen(),
                    transition: Transition.rightToLeft,
                  );
                },
                title: 'Withdraw Crypto',
                subTitle:
                'Withdraw crypto to other exchanges/wallets',
                leadingWidget: const Icon(
                  CupertinoIcons.arrow_up_to_line_alt,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 10),

              // ── 3. Withdraw USD ───────────────────────────────────────
              AddFundModalTile(
                onTap: () {},
                title: 'Withdraw USD',
                subTitle: 'Sell crypto for USD and withdraw via SWIFT',
                leadingWidget: const Icon(
                    Icons.attach_money, color: AppColors.white),
              ),

              const SizedBox(height: 10),

              // ── 4. P2P Trading ────────────────────────────────────────
              // ✅ Using Icon instead of missing p2p_trading.svg asset
              AddFundModalTile(
                onTap: () {},
                title: 'P2P Trading',
                subTitle: 'Sell directly to users. Competitive pricing.',
                leadingWidget: const Icon(
                    Icons.people_alt_outlined, color: AppColors.white),
              ),

              const SizedBox(height: AppSizes.xxxL),
            ],
          ),
        ),
      );
    },
  );
}