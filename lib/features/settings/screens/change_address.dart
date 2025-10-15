// lib/features/settings/views/change_address_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/features/settings/model/crypto_address_model.dart';
import '../../../core/utils/custom_loader.dart';
import '../controllers/change_address_controller.dart';

class ChangeAddressPage extends GetView<ChangeAddressController> {
  const ChangeAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChangeAddressController());

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.white),
        ),
        title: const Text(
          'Change Address',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: AppSizes.fontSizeH3,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: controller.addNewAddress,
            child: const Text(
              'New',
              style: TextStyle(
                color: AppColors.green,
                fontSize: AppSizes.fontSizeBodyM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[

          // Address List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CustomLoading());
              }

              if (controller.filteredAddresses.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontal,
                  vertical: AppSizes.sm,
                ),
                itemCount: controller.filteredAddresses.length,
                itemBuilder: (BuildContext context, int index) {
                  final CryptoAddressModel address = controller.filteredAddresses[index];
                  return _buildAddressItem(address, context);
                },
              );
            }),
          ),
        ],
      ),
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.textGreyLight.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            controller.searchQuery.value.isEmpty ? 'No addresses yet' : 'No addresses found',
            style: TextStyle(
              color: AppColors.textGreyLight.withValues(alpha: 0.7),
              fontSize: AppSizes.fontSizeBodyM,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          if (controller.searchQuery.value.isEmpty)
            ElevatedButton.icon(
              onPressed: controller.addNewAddress,
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(CryptoAddressModel address, BuildContext context) {
    return Obx(() {
      final bool isSelected = controller.selectedAddress.value?.id == address.id;

      return Material(
        color: AppColors.primaryColor,
        child: InkWell(

          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          splashColor: AppColors.green.withValues(alpha: 0.25),
          highlightColor: AppColors.greenAccent.withValues(alpha: 0.1),
          onTap: () => controller.selectAddress(address),
           child: Container(
             padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              border: Border.all(
                color: isSelected ? AppColors.green : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header with network name
                Row(
                  children: <Widget>[
                    Text(
                      address.label ?? address.network.toUpperCase(),

                    ),
                    const Spacer(),

                     IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textGreyLight, size: 20),
                      onPressed: () => _showAddressOptions(context, address),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),


                // Address
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _formatAddress(address.address),
                        style: TextStyle(
                          color: AppColors.textGreyLight.withValues(alpha: 0.8),
                          fontSize: AppSizes.fontSizeBodyS,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppColors.textGreyLight, size: 18),
                      onPressed: () => _copyAddress(address.address),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _formatAddress(String address) {
    // Format long addresses for better readability
    if (address.length > 42) {
      return '${address.substring(0, 20)}...${address.substring(address.length - 20)}';
    }
    return address;
  }

  void _copyAddress(String address) {
    Clipboard.setData(ClipboardData(text: address));
    Get.snackbar(
      'Copied',
      'Address copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.green.withValues(alpha: 0.8),
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(AppSizes.md),
    );
  }

  void _showAddressOptions(BuildContext context, CryptoAddressModel address) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.borderRadiusXxl)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textGreyLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Address preview
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  _formatAddress(address.address),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Divider(color: AppColors.iconBackground, height: 1),

              // Options
              ListTile(
                leading: const Icon(Icons.copy, color: AppColors.textWhite),
                title: const Text('Copy Address', style: TextStyle(color: AppColors.textWhite)),
                onTap: () {
                  Get.back();
                  _copyAddress(address.address);
                },
              ),

              if (!address.isDefault)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: AppColors.green),
                  title: const Text('Set as Default', style: TextStyle(color: AppColors.textWhite)),
                  onTap: () {
                    Get.back();
                    controller.setAsDefault(address);
                  },
                ),

              if (!address.isDefault)
                ListTile(
                  leading: const Icon(CupertinoIcons.delete, color: AppColors.red),
                  title: const Text('Delete Address', style: TextStyle(color: AppColors.red)),
                  onTap: () {
                    Get.back();
                    _showDeleteConfirmation(context, address);
                  },
                ),

              const SizedBox(height: AppSizes.sm),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, CryptoAddressModel address) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Delete Address', style: TextStyle(color: AppColors.textWhite)),
        content: const Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(color: AppColors.textGreyLight),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGreyLight)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAddress(address);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
