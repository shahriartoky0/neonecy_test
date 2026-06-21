// lib/features/trade/widgets/confirm_order_dialog.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/config/app_sizes.dart';
import '../../../core/design/app_colors.dart';
import '../../assets/model/coin_model.dart';

class ConfirmOrderDialog {
  static Future<bool?> show(
      BuildContext context, {
        required CoinItem fromCoin,
        required CoinItem toCoin,
        required String fromAmount,
        required String toAmount,
      }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ConfirmOrderBottomSheet(
        fromCoin: fromCoin,
        toCoin: toCoin,
        fromAmount: fromAmount,
        toAmount: toAmount,
      ),
    );
  }
}

class _ConfirmOrderBottomSheet extends StatefulWidget {
  final CoinItem fromCoin;
  final CoinItem toCoin;
  final String fromAmount;
  final String toAmount;

  const _ConfirmOrderBottomSheet({
    required this.fromCoin,
    required this.toCoin,
    required this.fromAmount,
    required this.toAmount,
  });

  @override
  State<_ConfirmOrderBottomSheet> createState() =>
      _ConfirmOrderBottomSheetState();
}

class _ConfirmOrderBottomSheetState extends State<_ConfirmOrderBottomSheet> {
  static const int _totalSeconds = 10;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        if (mounted) Navigator.pop(context, true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String rateText = _buildRateText();

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.borderRadiusXxl)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.lg, AppSizes.sm, AppSizes.lg, AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Header ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Confirm Order',
                    style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: AppSizes.fontSizeH3,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    color: AppColors.textGreyLight,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // ── From section ─────────────────────────────────────
              Text('From',
                  style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: AppSizes.fontSizeBodyS)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: <Widget>[
                  _buildCoinIcon(widget.fromCoin, AppColors.green),
                  const SizedBox(width: AppSizes.md),
                  Text(
                    widget.fromCoin.symbol,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    widget.fromAmount,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Inline rate below FROM
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  rateText,
                  style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: 11),
                ),
              ),

              const SizedBox(height: AppSizes.md),
               const SizedBox(height: AppSizes.md),

              // ── To section ───────────────────────────────────────
              Text('To',
                  style: const TextStyle(
                      color: AppColors.textGreyLight,
                      fontSize: AppSizes.fontSizeBodyS)),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: <Widget>[
                  _buildCoinIcon(widget.toCoin, AppColors.yellow),
                  const SizedBox(width: AppSizes.md),
                  Text(
                    widget.toCoin.symbol,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    widget.toAmount,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.lg),
              const Divider(color: AppColors.iconBackground, thickness: 1),
              const SizedBox(height: AppSizes.md),

              // ── Transaction Fees ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Transaction Fees',
                    style: TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS),
                  ),
                  Text(
                    '0 ${widget.toCoin.symbol}',
                    style: const TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.lg),

              // ── Confirm button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm (${_secondsLeft}s)',
                    style: const TextStyle(
                        fontSize: AppSizes.fontSizeBodyM,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinIcon(CoinItem coin, Color fallbackColor) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
          color: AppColors.iconBackground, shape: BoxShape.circle),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: coin.thumb,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            color: fallbackColor.withValues(alpha: 0.3),
            child: Center(
              child: Text(
                coin.symbol.isNotEmpty ? coin.symbol[0] : '?',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildRateText() {
    final double from = _parseAmount(widget.fromAmount);
    final double to = _parseAmount(widget.toAmount);
    if (from > 0 && to > 0) {
      final double rate = to / from;
      return '1 ${widget.fromCoin.symbol} = ${_formatAmount(rate)} ${widget.toCoin.symbol} ⇄';
    }
    return '1 ${widget.fromCoin.symbol} = 0 ${widget.toCoin.symbol} ⇄';
  }

  double _parseAmount(String a) =>
      double.tryParse(a.replaceAll(',', '')) ?? 0.0;

  String _formatAmount(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(5);
    if (v >= 0.0001) return v.toStringAsFixed(6);
    if (v > 0) return v.toStringAsFixed(8);
    return '0';
  }
}
