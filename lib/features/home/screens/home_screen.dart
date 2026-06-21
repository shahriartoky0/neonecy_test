import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/common/widgets/custom_modal.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/design/app_images.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/routes/app_routes.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import 'package:neonecy_test/features/auth/controllers/login_controller.dart';
import 'package:neonecy_test/features/home/controllers/crypto_market_controller.dart';
import 'package:neonecy_test/features/settings/controllers/settings_bottom_nav.dart';
import 'package:neonecy_test/features/wallet/controllers/wallet_controller.dart';
import '../../assets/widgets/add_fund_button_modal.dart';
import '../controllers/home_controller.dart';
import '../widgets/crypto_market.dart';
import '../widgets/custom_refresher.dart';
import '../widgets/discover_post_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CryptoMarketController cryptoMarketController = Get.put(CryptoMarketController());
    final WalletController walletController = Get.find<WalletController>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return AppBar(
            toolbarHeight: controller.showSpace.value ? 0 : kToolbarHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Colors.transparent, Colors.transparent],
                ),
              ),
            ),
            title: AnimatedOpacity(
              opacity: controller.showSpace.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      appbarIcon(
                        assetPath: AppIcons.appbarLeft,
                        onTap: () {
                          CustomBottomSheet.show(
                            height: context.screenHeight * 0.25,
                            context: context,
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Do you want to Logout ?',
                                    style: context.txtTheme.titleMedium?.copyWith(
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.md),
                                  Row(
                                    spacing: AppSizes.sm,
                                    children: <Widget>[
                                      Expanded(
                                        child: AppButton(
                                          labelText: 'No',
                                          onTap: () => Navigator.pop(context),
                                          bgColor: AppColors.yellow,
                                          textColor: AppColors.black,
                                        ),
                                      ),
                                      Expanded(
                                        child: AppButton(
                                          labelText: 'Yes',
                                          onTap: () {
                                            final LoginController loginController =
                                                Get.put(LoginController());
                                            loginController.logOut();
                                          },
                                          bgColor: AppColors.red,
                                          textColor: AppColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        height: 13,
                      ),
                      Obx(() => IconButton(
                            onPressed: () {},
                            icon: Badge(
                              backgroundColor: AppColors.yellow,
                              label: Text(
                                '${controller.messageCount.value}',
                                style: const TextStyle(color: AppColors.black, fontSize: 10),
                              ),
                              child: const Icon(Icons.message_outlined,
                                  color: AppColors.white, size: 20),
                            ),
                          )),
                      const SizedBox(width: 6),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.iconBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(
                        () => Row(
                          children: <Widget>[
                            topTabButton(
                              label: 'Exchange',
                              isSelected: controller.isExchangeSelected(),
                              onTap: () => controller.selectTab(0),
                            ),
                            topTabButton(
                              label: 'Wallet',
                              isSelected: controller.isWalletSelected(),
                              onTap: () => controller.selectTab(1),
                            ),
                          ],
                        ),
                      ),
                    ).centered,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              appbarIcon(assetPath: AppIcons.appbarHeadphone, onTap: () {}),
              const SizedBox(width: AppSizes.sm),
              appbarIcon(
                assetPath: AppIcons.appbarCoin,
                onTap: () {
                  Get.find<SettingsBottomNavController>().resetToHomePage();
                  Get.toNamed(AppRoutes.settingNavScreen);
                },
              ),
              const SizedBox(width: AppSizes.iconXs),
            ],
          );
        }),
      ),
      body: Stack(
        children: <Widget>[
          // ── Main scrollable content ──────────────────────────────────
          CustomGifRefreshWidget(
            onRefresh: () async => controller.onRefresh(),
            onRefreshStart: () => controller.showSpace.value = true,
            onRefreshComplete: () => controller.showSpace.value = false,
            gifAssetPath: AppImages.loader,
            refreshTriggerDistance: 80.0,
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: AppSizes.md),

                          // ── Search bar ──────────────────────────────
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              style: const TextStyle(color: AppColors.textWhite),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: AppSizes.sm),
                                hint: Obx(
                                  () => AnimatedOpacity(
                                    opacity: controller.showSpace.value ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 800),
                                    child: Text(
                                      controller.hintText.value,
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.hintText),
                                    ),
                                  ),
                                ),
                                suffixIcon: const Icon(CupertinoIcons.search,
                                    color: AppColors.textGreyLight),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),

                          // ── Est. Total Value label ──────────────────
                          Text(
                            'Est.Total Value(USD) ^',
                            style: TextStyle(
                                color: AppColors.textWhite.withValues(alpha: 0.85)),
                          ),
                          const SizedBox(height: AppSizes.md),

                          // ── Balance + Add Funds button ──────────────
                          Row(
                            spacing: AppSizes.md,
                            children: <Widget>[
                              Expanded(
                                child: Obx(
                                  () => Text(
                                    '\$ ${controller.balance.value}',
                                    style: context.txtTheme.displayMedium
                                        ?.copyWith(fontSize: 26),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              AppButton(
                                width: 100,
                                bgColor: AppColors.yellow,
                                textColor: AppColors.black,
                                labelText: 'Add Funds',
                                onTap: () => showAddFundModal(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),

                          // ── Dynamic PNL row ─────────────────────────
                          Obx(() {
                            final coins = walletController.walletCoins;
                            final double pnl =
                                coins.fold(0.0, (s, c) => s + c.profitLoss);
                            final double pnlPct = coins.isNotEmpty
                                ? coins.fold(
                                        0.0,
                                        (s, c) => s + c.profitLossPercent) /
                                    coins.length
                                : 0.0;
                            final bool isPos = pnl >= 0;
                            return Row(
                              children: <Widget>[
                                const Text(
                                  "Today's PNL ",
                                  style: TextStyle(
                                      color: AppColors.textGreyLight, fontSize: 11),
                                ),
                                Text(
                                  '${isPos ? '+' : ''}\$${pnl.abs().toStringAsFixed(4)} '
                                  '(${isPos ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                    color:
                                        isPos ? AppColors.greenAccent : AppColors.red,
                                    fontSize: 10,
                                  ),
                                ),
                                Icon(
                                  isPos
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: isPos ? AppColors.greenAccent : AppColors.red,
                                  size: 14,
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: AppSizes.md),

                          // ── Quick route icons ───────────────────────
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: AppSizes.md,
                              children: <Widget>[
                                quickRouteWidget(
                                  label: 'Rewards \nHub',
                                  assetPath: AppIcons.homeReward,
                                  onTap: () {},
                                ),
                                quickRouteWidget(
                                  label: 'Sharia Earn',
                                  assetPath: AppIcons.homeSharia,
                                  onTap: () {},
                                ),
                                quickRouteWidget(
                                  label: 'Referral',
                                  assetPath: AppIcons.homeReferral,
                                  onTap: () {},
                                ),
                                quickRouteWidget(
                                  label: 'Simple Earn',
                                  assetPath: AppIcons.homeSimpleEarn,
                                  onTap: () {},
                                ),
                                quickRouteWidget(
                                  label: 'More',
                                  assetPath: AppIcons.homeMore,
                                  onTap: () {},
                                ),
                              ],
                            ).centered,
                          ),
                          const SizedBox(height: AppSizes.md),

                          // ── Crypto market table ─────────────────────
                          const CryptoMarketWidget(),
                          const SizedBox(height: AppSizes.md),
                        ],
                      ),
                    ),
                  ),

                  // ── Sticky tab bar ──────────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        controller: controller.tabController,
                        dividerColor: Colors.transparent,
                        isScrollable: true,
                        indicatorColor: AppColors.yellow,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorPadding:
                            const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                        indicatorWeight: 1,
                        tabAlignment: TabAlignment.center,
                        labelColor: AppColors.textWhite,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 17),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: AppColors.textGreyLight,
                        ),
                        tabs: controller.homeTabTitles
                            .map((String title) => Tab(child: Text(title)))
                            .toList(),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: controller.tabController,
                children: <Widget>[
                  // ── Discover tab ──────────────────────────────────
                  NotificationListener<ScrollUpdateNotification>(
                    onNotification: (ScrollUpdateNotification n) {
                      controller.onDiscoverScroll(n.metrics.pixels);
                      return false;
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: AppSizes.sm),
                          const Divider(),
                          Obx(() => Column(
                                children: controller.displayedPosts
                                    .map(
                                      (post) => Column(
                                        children: <Widget>[
                                          StockCard(
                                            username: post.username,
                                            timeAgo: post.timeAgo,
                                            symbol: post.symbol,
                                            question: post.question,
                                            imagePath: post.imagePath,
                                            priceChange: post.priceChange,
                                            isPositive: post.isPositive,
                                            comments: post.comments,
                                            likes: post.likes,
                                            reposts: post.reposts,
                                            shares: post.shares,
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              )),
                          // Bottom padding so content clears the floating buttons
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  // ── Other tabs ────────────────────────────────────
                  const Center(child: Text('Following UI appear here')),
                  const Center(child: Text('Campaign UI appear here')),
                  const Center(child: Text('News UI appear here')),
                  const Center(child: Text('Announcement UI appear here')),
                ],
              ),
            ),
          ),

          // ── Floating plus button (visible when scrolled to posts) ───
          Positioned(
            right: 16,
            bottom: 20,
            child: Obx(
              () => IgnorePointer(
                ignoring: !controller.showFloatingPlus.value,
                child: AnimatedOpacity(
                  opacity: controller.showFloatingPlus.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _buildFloatingPlusButton(),
                ),
              ),
            ),
          ),

          // ── Floating AI button (visible when at top content) ──────
          Positioned(
            right: 16,
            bottom: 20,
            child: Obx(
              () => IgnorePointer(
                ignoring: !controller.showFloatingAi.value,
                child: AnimatedOpacity(
                  opacity: controller.showFloatingAi.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const _FloatingAiButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingPlusButton() {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
              // boxShadow: <BoxShadow>[
              //   BoxShadow(
              //     color: AppColors.yellow.withValues(alpha: 0.4),
              //     blurRadius: 12,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 30),
          ),
          // Notification badge
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column quickRouteWidget({
    required String label,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return Column(
      spacing: 4,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXl),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusXl),
            splashColor: AppColors.iconBackgroundLight,
            onTap: () {
              DeviceUtility.hapticFeedback();
              onTap();
            },
            child: CustomSvgImage(assetName: assetPath, height: 40),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textGreyLight),
        ),
      ],
    );
  }

  Expanded topTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.iconBackgroundLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
              color: isSelected ? AppColors.textWhite : AppColors.textGreyLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Material appbarIcon({
    required String assetPath,
    required VoidCallback onTap,
    double height = 15,
  }) {
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
          padding: const EdgeInsets.all(2.0),
          child: CustomSvgImage(assetName: assetPath, height: height),
        ),
      ),
    );
  }
}

// ── Floating AI button widget ──────────────────────────────────────────────────
// TODO: Replace emoji avatar with CustomSvgImage(AppIcons.aiFloatingButton)
// once assets/icons/ai_button.svg is provided.
class _FloatingAiButton extends StatelessWidget {
  const _FloatingAiButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text('🤖', style: TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}

// ── Sticky tab bar delegate ────────────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => tabBar != oldDelegate.tabBar;
}