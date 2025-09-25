import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_images.dart';
import 'package:neonecy_test/core/extensions/widget_extensions.dart';
import 'package:neonecy_test/features/splash/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SplashController _ = controller;

    /// initialize the controller
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.splashBgColor,
      ),
      backgroundColor: AppColors.splashBgColor,
      body: SafeArea(child: Image.asset(AppImages.firstSplash).centered),
    );
  }
}
