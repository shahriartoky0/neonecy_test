import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/core/utils/device/device_utility.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Row(

              children: <Widget>[
                appbarIcon(assetPath: AppIcons.appbarLeft, onTap: () {}),
                IconButton(
                  onPressed: () {},
                  icon: Badge(
                    backgroundColor: AppColors.yellow,
                    label: Text('22', style: TextStyle(color: AppColors.black, fontSize: 10)),
                    child: const Icon(Icons.message_outlined, color: AppColors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBar(
                controller: controller.tabController,
                dividerColor: Colors.transparent,
                isScrollable: true,
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 5,
                tabAlignment: TabAlignment.center,
                labelColor: Colors.black87,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                tabs: const <Widget>[
                  Tab(child: Text("Exchange")),
                  Tab(child: Text("Wallet")),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          appbarIcon(assetPath: AppIcons.appbarHeadphone, onTap: () {}),
          SizedBox(width: AppSizes.sm),
          appbarIcon(assetPath: AppIcons.appbarCoin, onTap: () {}),
          SizedBox(width: AppSizes.iconXs),
        ],
      ),
      body: Expanded(
        child: TabBarView(
          controller: controller.tabController,
          children: <Widget>[
            /// ========== > Exchange Tab view =====>
            TextFormField(
              decoration: InputDecoration(
                hintText: '#BinanceHODLerPLUME',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(AppSizes.iconXs),
                  child: CustomSvgImage(assetName: AppIcons.search, color: AppColors.textGreyLight),
                ),
              ),
            ),

            /// ========== > Wallet Tab view =====>
            Text("Wallet UI appear here", style: context.txtTheme.headlineMedium).centered,
          ],
        ),
      ),
    );
  }

  Material appbarIcon({required String assetPath, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        splashColor: AppColors.primaryColor,
        onTap: (){
          DeviceUtility.hapticFeedback() ;
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CustomSvgImage(assetName: assetPath),
        ),
      ),
    );
  }
}
