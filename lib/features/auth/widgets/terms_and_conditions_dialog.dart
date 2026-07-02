import 'package:flutter/material.dart';
import 'package:neonecy_test/core/common/widgets/app_button.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/config/app_url.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/network/network_caller.dart';
import 'package:neonecy_test/core/network/network_response.dart';
import 'package:neonecy_test/core/utils/custom_loader.dart';

/// Dark themed dialog that fetches and displays the terms & conditions
/// from [AppUrl.termsAndConditions].
class TermsAndConditionsDialog extends StatefulWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  State<TermsAndConditionsDialog> createState() => _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool _isLoading = true;
  String? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    try {
      final NetworkResponse response = await NetworkCaller().getRequest(
        AppUrl.termsAndConditions,
      );
      if (!mounted) {
        return;
      }
      if (response.isSuccess) {
        setState(() {
          _content = _extractContent(response.jsonResponse);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.jsonResponse?['message']?.toString() ??
              'Failed to load terms & conditions.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Failed to load terms & conditions.';
        _isLoading = false;
      });
    }
  }

  String _extractContent(Map<String, dynamic>? json) {
    if (json == null) {
      return '';
    }
    final dynamic data =
        json['data'] ?? json['terms_and_conditions'] ?? json['content'] ?? json['message'];
    if (data is String) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final dynamic inner =
          data['content'] ?? data['terms_and_conditions'] ?? data['text'] ?? data['body'];
      if (inner is String) {
        return inner;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xxl),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: AppColors.textGreyLight, size: 22),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(color: AppColors.textGreyLight, thickness: 0.3),
            const SizedBox(height: AppSizes.sm),
            Flexible(
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.xxl),
                      child: CustomLoading(size: 40),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _error ??
                            (_content?.isNotEmpty == true
                                ? _content!
                                : 'No terms & conditions available.'),
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              labelText: 'Close',
              bgColor: AppColors.yellow,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
