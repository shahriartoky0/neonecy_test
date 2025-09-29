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
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import 'package:neonecy_test/features/auth/controllers/login_controller.dart';
import 'package:neonecy_test/features/home/controllers/crypto_market_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/crypto_market.dart';
import '../widgets/custom_refresher.dart';
import '../widgets/discover_post_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CryptoMarketController cryptoMarketController = Get.put(CryptoMarketController());
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
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: controller.showSpace.value
                    ? AppColors.reversedPrimaryGradient
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Colors.transparent, Colors.transparent],
                      ),
              ),
            ),
            title: AnimatedOpacity(
              opacity: controller.showSpace.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 800),
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
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          bgColor: AppColors.yellow,
                                          textColor: AppColors.black,
                                        ),
                                      ),
                                      Expanded(
                                        child: AppButton(
                                          labelText: 'Yes',
                                          onTap: () {
                                            /// =====> Logout logic =====>
                                            final LoginController loginController = Get.put(
                                              LoginController(),
                                            );
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
                      IconButton(
                        onPressed: () {},
                        icon: const Badge(
                          backgroundColor: AppColors.yellow,
                          label: Text('22', style: TextStyle(color: AppColors.black, fontSize: 10)),
                          child: Icon(Icons.message_outlined, color: AppColors.white, size: 20),
                        ),
                      ),
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
                              onTap: () {
                                controller.selectTab(0);
                              },
                            ),
                            topTabButton(
                              label: 'Wallet',
                              isSelected: controller.isWalletSelected(),
                              onTap: () {
                                controller.selectTab(1);
                              },
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
              appbarIcon(assetPath: AppIcons.appbarCoin, onTap: () {}),
              const SizedBox(width: AppSizes.iconXs),
            ],
          );
        }),
      ),
      body: CustomGifRefreshWidget(
        onRefresh: () async {
          await controller.onRefresh();
        },

        gifAssetPath: AppImages.loader, // Your gif asset path
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
                      SizedBox(
                        height: 40,

                        /// TODO : make a scrolling type animation simply
                        child: TextFormField(
                          style: const TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: AppSizes.sm,
                            ),
                            hint: Obx(
                              () => AnimatedOpacity(
                                opacity: controller.showSpace.value ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  controller.hintText.value,
                                  style: const TextStyle(fontSize: 12, color: AppColors.hintText),
                                ),
                              ),
                            ),
                            suffixIcon: const Icon(
                              CupertinoIcons.search,
                              color: AppColors.textGreyLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Est.Total Value(USD) ^',
                        style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.85)),
                      ),
                      const SizedBox(height: AppSizes.md),

                      /// ========> The dollar amount and the add fund button  =======>
                      Row(
                        spacing: AppSizes.md,
                        children: <Widget>[
                          Expanded(
                            child: Obx(
                              () => Text(
                                '\$ ${controller.balance.value}',
                                style: context.txtTheme.displayMedium?.copyWith(fontSize: 26),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          AppButton(
                            width: 100,
                            bgColor: AppColors.yellow,
                            textColor: AppColors.black,
                            labelText: 'Add Funds',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),

                      /// ========> The PNL percentage =======>
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Today's PNL ",
                            style: TextStyle(color: AppColors.white, fontSize: 11),
                          ),
                          Text(
                            "+\$0.00146468 (+0.50%) ",
                            style: TextStyle(color: AppColors.green, fontSize: 10),
                          ),
                          Text("V", style: TextStyle(color: AppColors.green, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      /// ========> Different Icons with routes =======>
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

                      /// ================> The Crypto Table ==============>
                      const CryptoMarketWidget(),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),

              // Sticky TabBar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: controller.tabController,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    indicatorColor: AppColors.yellow,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    indicatorWeight: 1,
                    tabAlignment: TabAlignment.center,
                    labelColor: AppColors.textWhite,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
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
              /// ========== > Discover View ======>
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: AppSizes.sm),
                    const Divider(),
                    StockCard(
                      username: "FARUK",
                      timeAgo: "3h ",
                      symbol: "SOM",
                      question: "Again possible or not ?",
                      imagePath: AppImages.demoImage,
                      priceChange: "-11.88%",
                      isPositive: false,
                      comments: 12,
                      likes: 19,
                      reposts: 18,
                      shares: 0,
                    ),
                    const Divider(),
                    // Added more cards here for testing scrolling
                    StockCard(
                      username: "ALICE",
                      timeAgo: "1h ",
                      symbol: "BTC",
                      question: "Will it drop below 40k?",
                      imagePath: AppImages.demoImage,
                      priceChange: "+2.45%",
                      isPositive: true,
                      comments: 8,
                      likes: 25,
                      reposts: 12,
                      shares: 3,
                    ),
                  ],
                ),
              ),

              /// ========== > Other Tab view =====>
              const Text("Following UI appear here").centered,
              const Text("Campaign UI appear here").centered,
              const Text("News UI appear here").centered,
              const Text("Announcement UI appear here").centered,
            ],
          ),
        ),
      ),
    );
  }

  /// =====> The widget of icon in the rows  ============>
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

  /// ==========> for the exchange and wallet button ===========>
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

  /// ========> App Bar Icons with clicking effects ============>
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

// Custom SliverPersistentHeaderDelegate for the sticky TabBar
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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
