import 'package:flutter/material.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_images.dart';

class TradePreviewLoader {
  static Future<void> show(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (_) => const _LoaderDialog(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

class _LoaderDialog extends StatelessWidget {
  const _LoaderDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.iconBackgroundLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset(AppImages.loader),
        ),
      ),
    );
  }
}
