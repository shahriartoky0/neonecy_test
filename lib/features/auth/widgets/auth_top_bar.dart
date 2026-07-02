import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';

/// Top bar used across the auth flow.
/// Entry screens show a close (X) icon, step screens show a back arrow.
class AuthTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isRoot;
  final bool showHeadphone;
  final VoidCallback? onBack;

  const AuthTopBar({super.key, this.isRoot = false, this.showHeadphone = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              onPressed: onBack ?? Get.back,
              icon: Icon(
                isRoot ? Icons.close : Icons.arrow_back,
                color: AppColors.white,
              ),
            ),
            if (showHeadphone)
              IconButton(
                onPressed: () {},
                icon: CustomSvgImage(
                  assetName: AppIcons.appbarHeadphone,
                  width: 18,
                  height: 18,
                  color: AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}