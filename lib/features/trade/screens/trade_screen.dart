import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/features/trade/controllers/trade_controller.dart';
import 'package:neonecy_test/features/trade/screens/trade_convert_screen.dart';
import '../../markets/controllers/markets_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';

class TradeScreen extends GetView<TradeController> {
  const TradeScreen({super.key});

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
            tabs: controller.homeTabTitles.map((String title) => Tab(child: Text(title))).toList(),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const Divider(),
          // TabBarView section - Takes remaining space
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: <Widget>[
                /// ========== > Discover View ======>
                const TradeConvertScreen(),

                /// ========== > Other Tab views =====>
                const Text("Sport UI appear here").centered,
                const Text("Margin UI appear here").centered,
                const Text("Buy/sell UI appear here").centered,
                const Text("p2 UI appear here").centered,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
