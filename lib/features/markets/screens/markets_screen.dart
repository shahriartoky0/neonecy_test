import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/features/home/widgets/custom_refresher.dart';
import '../../../core/design/app_images.dart';
import '../controllers/markets_controller.dart';
import '../widget/enhanced_crupto.dart';

class MarketsScreen extends GetView<MarketsController> {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: controller.onRefreshState.value
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.transparent, Colors.transparent],
                )
                    : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.transparent, Colors.transparent],
                ),
              ),
            ),
            title: AnimatedOpacity(
              opacity: controller.onRefreshState.value ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 800),
              child: const TextField(
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  prefixIcon: Icon(CupertinoIcons.search, color: AppColors.textGreyLight),
                  hintText: 'Search Coin Pairs',
                ),
              ),
            ),
            actions: <Widget>[
              AnimatedOpacity(
                opacity: controller.onRefreshState.value ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 800),
                child: IconButton(
                  onPressed: () {},
                  icon: CustomSvgImage(assetName: AppIcons.marketMenu, height: 4),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomGifRefreshWidget(
        onRefresh: () async {
          await controller.onRefresh();
        },

        gifAssetPath: AppImages.loader, // Your gif asset path
        refreshTriggerDistance: 80.0,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // TabBar section
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
              const Divider(),
              // TabBarView with fixed height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.85, // 70% of screen height
                child: TabBarView(
                  controller: controller.tabController,
                  children: <Widget>[
                    /// ========== > Discover View ======>
                    const EnhancedCryptoMarketWidget(),

                    /// ========== > Other Tab views =====>
                    const Text("Market UI appear here").centered,
                    const Text("Alpha UI appear here").centered,
                    const Text("Grow UI appear here").centered,
                    const Text("Square UI appear here").centered,
                    const Text("Database UI appear here").centered,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
