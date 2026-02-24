// lib/features/assets/screens/assets_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/features/assets/controllers/assessment_top_tab_controller.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_images.dart';
import '../../home/widgets/custom_refresher.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../controllers/assets_controller.dart';
import 'asset_funding.dart';
import 'asset_overview_screen.dart';

class AssetsScreen extends GetView<AssetsController> {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AssetTopTabController tabCtrl = Get.put(AssetTopTabController());
    final WalletController walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
              () => AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            title: AnimatedOpacity(
              opacity: controller.onRefreshState.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 800),
              child: SizedBox(
                height: 60,
                child: TabBar(
                  controller: tabCtrl.tabController,
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                  indicatorWeight: 1,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.textWhite,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 17),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.textGreyLight),
                  tabs: tabCtrl.assetTabTitles
                      .map((t) => Tab(child: Text(t)))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomGifRefreshWidget(
        gifAssetPath: AppImages.loader,
        refreshTriggerDistance: 80.0,
        onRefreshStart: () => controller.onRefreshState.value = true,
        onRefreshComplete: () => controller.onRefreshState.value = false,
        onRefresh: () async {
          await controller.onRefresh();
          await walletController.fetchWalletCoins();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Column(
            children: [
              const Divider(),
              Expanded(
                child: TabBarView(
                  controller: tabCtrl.tabController,
                  children: [
                    // ── Each child MUST be a SingleChildScrollView with
                    // AlwaysScrollableScrollPhysics so scroll notifications
                    // bubble up to CustomGifRefreshWidget even when content
                    // is shorter than the screen (no natural overscroll). ──

                    // Tab 0 — Overview (already SingleChildScrollView inside)
                    const AssetOverviewScreen(),

                    // Tab 1 — Funding (already SingleChildScrollView inside)
                    const AssetFundingScreen(),

                    // Tab 2 & 3 — placeholders wrapped so refresh works
                    _scrollablePlaceholder('Spot UI appear here'),
                    _scrollablePlaceholder('Futures UI appear here'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps a placeholder in a SingleChildScrollView with
  /// AlwaysScrollableScrollPhysics so pull-to-refresh fires even with
  /// minimal content.
  Widget _scrollablePlaceholder(String label) {
    return SingleChildScrollView(
      // ✅ Key fix: without AlwaysScrollableScrollPhysics, a short/empty
      // page produces no scroll events → CustomGifRefreshWidget never fires.
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400, // give it some height so overscroll is reachable
        child: Center(
          child: Text(label,
              style: const TextStyle(color: AppColors.textGreyLight)),
        ),
      ),
    );
  }
}