import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/features/assets/controllers/assessment_top_tab_controller.dart';
import '../../../core/common/widgets/custom_svg.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/utils/device/device_utility.dart';
import '../controllers/assets_controller.dart';
import 'asset_funding.dart';
import 'asset_overview_screen.dart';

class AssetsScreen extends GetView<AssetsController> {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AssetTopTabController assessmentTopTabController = Get.put(AssetTopTabController());
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 60, // Fixed height for TabBar
          child: TabBar(
            controller: assessmentTopTabController.tabController,
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
            tabs: assessmentTopTabController.assetTabTitles
                .map((String title) => Tab(child: Text(title)))
                .toList(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: AppSizes.md),
        child: Column(
          children: <Widget>[
            const Divider(),
            Expanded(
              child: TabBarView(
                controller: assessmentTopTabController.tabController,
                children: <Widget>[
                  /// ========== > Discover View ======>
                  const AssetOverviewScreen(),

                  /// ========== > Other Tab views =====>
                  const AssetFundingScreen(),
                  const Text("Spot UI appear here").centered,
                  const Text("Futures UI appear here").centered,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}


