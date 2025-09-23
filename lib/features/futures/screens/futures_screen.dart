import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/features/futures/controllers/futures_controller.dart';
import 'package:neonecy_test/features/futures/controllers/usd_controller.dart';
import 'package:neonecy_test/features/futures/screens/future_left.dart';
import 'package:neonecy_test/features/futures/screens/future_right.dart';

class FuturesScreen extends GetView<FuturesController> {
  const FuturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 60, // Fixed height for TabBar
          child: TabBar(
            controller: controller.tabController,
            dividerColor: Colors.transparent,
            isScrollable: true,
            indicatorColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            indicatorWeight: 1,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.textWhite,
            labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppColors.textGreyLight,
            ),
            tabs: controller.futureTabTitle.map((String title) => Tab(child: Text(title))).toList(),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Divider(),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: <Widget>[
                  /// ========== > USD View ======>
                  const UsdMScreen(),

                  /// ========== > Other Tab views =====>
                  const Text("COIN -M UI appear here").centered,
                  const Text("Options UI appear here").centered,
                  const Text("Smart UI appear here").centered,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsdMScreen extends StatelessWidget {
  const UsdMScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller instance
    final UsdController controller = Get.put(UsdController());

    return DefaultTabController(
      length: controller.usdTabTitle.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            // First section with FutureLeft and FutureRight
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Row(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 3, child: FutureLeft()),
                    Expanded(flex: 2, child: FutureRight()),
                  ],
                ),
              ),
            ),

            // TabBar as a Sliver
            SliverAppBar(
              pinned: true,
              // Keeps the tab bar at the top when scrolling
              floating: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              toolbarHeight: 0,
              // Remove default app bar height
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: TabBar(
                    controller: controller.tabController,
                    dividerColor: Colors.transparent,
                    isScrollable: true,

                    indicatorColor: AppColors.yellow,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                    indicatorWeight: 1,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.textWhite,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.textGreyLight,
                    ),
                    tabs: <Widget>[
                      const Tab(child: Text('Positions (0)')),
                      const Tab(child: Text('Open Orders (0)')),
                      const Tab(child: Text('Futures Grid')),
                      Tab(
                        child: CustomSvgImage(
                          assetName: AppIcons.assetHistory,
                          color: AppColors.textGreyLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: controller.tabController,
          children: <Widget>[
            /// ========== > Other Tab views =====>
            const Text("Positions UI appear here").centered,
            const Text("Orders UI appear here").centered,
            const Text("Futures Grid appear here").centered,
            const Text("History Grid appear here").centered,
          ],
        ),
      ),
    );
  }
}
