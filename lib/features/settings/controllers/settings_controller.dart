import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/utils/get_storage.dart';
import 'package:neonecy_test/core/config/app_constants.dart';

import '../../../core/design/app_colors.dart';

class SettingsController extends GetxController {
  final GetStorageModel _storageModel = GetStorageModel();

  // Reactive variables for profile information
  final RxString userName = ''.obs;
  final RxString binanceId = ''.obs;
  final Rx<File?> profileImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    // Load saved profile information on initialization
    _loadProfileInfo();
  }

  void _loadProfileInfo() {
    // Load username
    if (_storageModel.exists(AppConstants.usernameKey)) {
      userName.value = _storageModel.read(AppConstants.usernameKey) ?? '';
    }

    // Load Binance ID
    if (_storageModel.exists(AppConstants.binanceIdKey)) {
      binanceId.value = _storageModel.read(AppConstants.binanceIdKey) ?? '';
    }

    // Load profile image
    final String? imagePath = _storageModel.getImagePath(AppConstants.profileImageKey);
    if (imagePath != null && File(imagePath).existsSync()) {
      profileImage.value = File(imagePath);
    }
  }

  Future<void> updateUsername(String name) async {
    userName.value = name;
    await _storageModel.save(AppConstants.usernameKey, name);
  }

  Future<void> updateBinanceId(String id) async {
    binanceId.value = id;
    await _storageModel.save(AppConstants.binanceIdKey, id);
  }

  Future<void> pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show dialog for image source selection
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          backgroundColor: AppColors.bgColor,
          title: const Text('Choose Image Source', style: TextStyle(color: AppColors.textWhite)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.white),
                title: const Text('Gallery', style: TextStyle(color: AppColors.textWhite)),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: const Text('Camera', style: TextStyle(color: AppColors.textWhite)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        // Save image using GetStorageModel
        final String? savedImagePath = await _storageModel.saveImage(
          AppConstants.profileImageKey,
          imageFile,
        );

        if (savedImagePath != null) {
          profileImage.value = File(savedImagePath);
          ToastManager.show(message: 'Profile picture updated');
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ToastManager.show(
        message: 'Failed to pick image',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> saveProfile() async {
    // Validate and save all profile information
    if (userName.value.isNotEmpty) {
      await _storageModel.save(AppConstants.usernameKey, userName.value);
    }

    if (binanceId.value.isNotEmpty) {
      await _storageModel.save(AppConstants.binanceIdKey, binanceId.value);
    }

    Get.back(); // Optional: Navigate back after saving
  }
}