import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import '../controllers/markets_controller.dart';
import '../widget/enhanced_crupto.dart';

class MarketsScreen extends GetView<MarketsController> {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintStyle: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
            prefixIcon: Icon(CupertinoIcons.search, color: AppColors.textGreyLight),
            hintText: 'Search Coin Pairs',
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: CustomSvgImage(assetName: AppIcons.marketMenu, height: 4),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // TabBar section - Fixed height
          SizedBox(
            height: 60, // Fixed height for TabBar
            child: TabBar(
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

          // TabBarView section - Takes remaining space
          Expanded(
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
    );
  }
}
