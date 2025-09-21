import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/extensions/context_extensions.dart';
import '../../config/app_sizes.dart';
import '../../design/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final VoidCallback? onPressed;

  const CustomAppBar({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed:
            onPressed ??
            () {
              Get.back();
            },
        icon: const Icon(CupertinoIcons.back, size: 20, color: AppColors.primaryColor),
      ),
      centerTitle: true,
      title: Text(label, style: context.txtTheme.labelSmall),
      actions: const <Widget>[
        SizedBox(width: AppSizes.xxl),
        // You can add additional actions if necessary
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
