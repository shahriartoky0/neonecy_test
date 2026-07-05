// lib/features/assets/screens/withdraw_slip_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:neonecy_test/core/common/widgets/custom_svg.dart';
import 'package:neonecy_test/core/common/widgets/custom_toast.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';
import 'package:neonecy_test/core/design/app_icons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Withdraw Payment Slip — shown right after a successful withdraw and from
/// withdraw items in the transaction history. All detail fields are optional
/// so partially-recorded history entries still render safely.
class WithdrawSlipScreen extends StatelessWidget {
  final String symbol;
  final double? receiveAmount;
  final double? amount;
  final double? networkFee;
  final String? network;
  final String? address;
  final String? txid;
  final String walletName;
  final DateTime? date;

  const WithdrawSlipScreen({
    super.key,
    required this.symbol,
    this.receiveAmount,
    this.amount,
    this.networkFee,
    this.network,
    this.address,
    this.txid,
    this.walletName = 'Spot Wallet',
    this.date,
  });

  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  String _fmtAmount(double v) {
    if (v >= 1000) {
      return v.toStringAsFixed(2);
    }
    if (v >= 1) {
      return v.toStringAsFixed(4);
    }
    if (v >= 0.0001) {
      return v.toStringAsFixed(6);
    }
    if (v > 0) {
      return v.toStringAsFixed(8);
    }
    return '0';
  }

  String _trimZeros(String s) =>
      s.contains('.') ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '') : s;

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ToastManager.show(
      message: 'Copied to clipboard',
      backgroundColor: AppColors.greenContainer,
      textColor: AppColors.white,
      icon: const Icon(Icons.check_circle, color: AppColors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String headline = receiveAmount != null
        ? '-${_trimZeros(_fmtAmount(receiveAmount!))} $symbol'
        : '-- $symbol';

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: AppColors.textWhite, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Withdrawal Details',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: AppSizes.fontSizeH3,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          CustomSvgImage(assetName: AppIcons.appbarHeadphone, height: 20),
          const SizedBox(width: AppSizes.md),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSizes.xl),

            // ── Headline amount ────────────────────────────────────
            Text(
              headline,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.md),

            // ── Completed badge ────────────────────────────────────
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.check_circle, color: AppColors.green, size: 18),
                SizedBox(width: AppSizes.xs),
                Text('Completed', style: TextStyle(color: AppColors.green, fontSize: 14)),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Text(
                'Crypto transferred out of Binance. Please contact the recipient platform for your transaction receipt.',
                style: TextStyle(color: AppColors.textGreyLight, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Why hasn't my withdrawal arrived?",
                style: TextStyle(
                  color: AppColors.yellow,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSizes.lg),
            const Divider(color: AppColors.iconBackground),

            // ── Detail rows ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              child: Column(
                children: <Widget>[
                  _DetailRow(label: 'Network', valueWidget: _plainValue(network ?? '--')),
                  const SizedBox(height: AppSizes.lg),
                  _DetailRow(
                    label: 'Address',
                    valueWidget: _copyableValue(address),
                    below: address != null && address!.isNotEmpty
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.only(top: AppSizes.sm),
                                child: Text(
                                  'Save Address',
                                  style: TextStyle(
                                    color: AppColors.yellow,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _DetailRow(label: 'Txid', valueWidget: _copyableValue(txid, underline: true)),
                  const SizedBox(height: AppSizes.lg),
                  _DetailRow(
                    label: 'Amount',
                    valueWidget: _plainValue(
                      amount != null ? '${_trimZeros(_fmtAmount(amount!))} $symbol' : '--',
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _DetailRow(
                    label: 'Network fee',
                    valueWidget: _plainValue(
                      networkFee != null
                          ? '${_trimZeros(_fmtAmount(networkFee!))} $symbol'
                          : '--',
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _DetailRow(label: 'Wallet', valueWidget: _plainValue(walletName)),
                  const SizedBox(height: AppSizes.lg),
                  _DetailRow(
                    label: 'Date',
                    valueWidget: _plainValue(date != null ? _dateFmt.format(date!) : '--'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // ── Scam Report ────────────────────────────────────────
            GestureDetector(
              onTap: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.report_outlined, color: AppColors.textGreyLight, size: 18),
                  SizedBox(width: AppSizes.xs),
                  Text(
                    'Scam Report',
                    style: TextStyle(color: AppColors.textGreyLight, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),

      // ── Withdraw Again ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
        color: AppColors.bgColor,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
              ),
              onPressed: () => Get.back(),
              child: const Text(
                'Withdraw Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _plainValue(String value) => Text(
        value,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.right,
      );

  Widget _copyableValue(String? value, {bool underline = false}) {
    if (value == null || value.isEmpty) {
      return _plainValue('--');
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              decoration: underline ? TextDecoration.underline : null,
              decorationColor: AppColors.textWhite,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        GestureDetector(
          onTap: () => _copy(value),
          child:   const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(PhosphorIconsLight.copy, color: AppColors.textGreyLight, size: 17),
          ),
        ),
      ],
    );
  }
}

// ── Label / value row ─────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final Widget? below;

  const _DetailRow({required this.label, required this.valueWidget, this.below});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: <Widget>[
            Expanded(
              flex: 1,

              child: Text(
                label,
                style: const TextStyle(color: AppColors.textGreyLight, fontSize: 14),
              ),
            ),
            const SizedBox(width: AppSizes.lg),
            Expanded(
              flex: 2,
              child: Align(alignment: Alignment.centerRight, child: valueWidget),
            ),
          ],
        ),
        if (below != null) below!,
      ],
    );
  }
}