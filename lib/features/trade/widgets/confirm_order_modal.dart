// lib/features/trade/widgets/confirm_order_dialog.dart
import 'dart:async';
import 'dart:math';
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

class _ConfirmOrderBottomSheetState extends State<_ConfirmOrderBottomSheet>
    with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 10;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  // AnimationController drives the sweeping hand on the stopwatch
  late final AnimationController _handCtrl;

  @override
  void initState() {
    super.initState();
    _handCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // hand sweeps every second

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
    _handCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double fromUSD =
        _parseAmount(widget.fromAmount) * widget.fromCoin.price;
    final double toUSD =
        _parseAmount(widget.toAmount) * widget.toCoin.price;

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.borderRadiusXxl)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg, vertical: AppSizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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

              _buildCoinSection(
                  label: 'From', coin: widget.fromCoin,
                  amount: widget.fromAmount, usdValue: fromUSD),

              const SizedBox(height: AppSizes.md),

              _buildCoinSection(
                  label: 'To', coin: widget.toCoin,
                  amount: widget.toAmount, usdValue: toUSD),

              const SizedBox(height: AppSizes.lg),
              const Divider(color: AppColors.iconBackground, thickness: 1),
              const SizedBox(height: AppSizes.md),

              _buildInfoRow('Type', 'Instant'),
              const SizedBox(height: AppSizes.sm),
              _buildInfoRow('Transaction Fees', '0.1%',
                  valueColor: AppColors.textGreyLight),
              const SizedBox(height: AppSizes.sm),
              _buildInfoRow('Rate', _buildRateText(),
                  valueColor: AppColors.textGreyLight),

              const SizedBox(height: AppSizes.lg),

              // ── Confirm button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    // ✅ Smaller vertical padding vs before (was height: 50)
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppSizes.borderRadiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: AppSizes.fontSizeBodyM,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: AppSizes.sm),

                      // ── Animated stopwatch pill ────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Animated stopwatch icon
                            AnimatedBuilder(
                              animation: _handCtrl,
                              builder: (_, __) {
                                // fillFraction drains smoothly every frame:
                                // starts at 1.0 (full), reaches 0.0 at end
                                final double fillFraction =
                                ((_secondsLeft - _handCtrl.value) /
                                    _totalSeconds)
                                    .clamp(0.0, 1.0);
                                return CustomPaint(
                                  size: const Size(16, 16),
                                  painter: _StopwatchPainter(
                                    handFraction: _handCtrl.value,
                                    fillFraction: fillFraction,
                                    color: AppColors.black,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${_secondsLeft}s',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.sm),
            ],
          ),
        ),
      ),
    );
  }

  // ── Unchanged helpers ────────────────────────────────────────────────────

  Widget _buildCoinSection({
    required String label,
    required CoinItem coin,
    required String amount,
    required double usdValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textGreyLight,
                fontSize: AppSizes.fontSizeBodyS)),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                  color: AppColors.iconBackground,
                  shape: BoxShape.circle),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: coin.thumb,
                  width: 32, height: 32, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color:
                    label == 'From' ? AppColors.green : AppColors.red,
                    child: Center(
                      child: Text(coin.symbol.substring(0, 1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Text(coin.symbol,
                style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppSizes.fontSizeBodyM,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: AppSizes.fontSizeBodyM,
                        fontWeight: FontWeight.w600)),
                Text(' \$${usdValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppColors.textGreyLight,
                        fontSize: AppSizes.fontSizeBodyS)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textGreyLight,
                fontSize: AppSizes.fontSizeBodyS)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? AppColors.textWhite,
                fontSize: AppSizes.fontSizeBodyS,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _buildRateText() {
    final double from = _parseAmount(widget.fromAmount);
    final double to = _parseAmount(widget.toAmount);
    if (from > 0) {
      return '1 ${widget.fromCoin.symbol} ≈ ${_formatAmount(to / from)} ${widget.toCoin.symbol}';
    }
    return '1 ${widget.fromCoin.symbol} ≈ 0 ${widget.toCoin.symbol}';
  }

  double _parseAmount(String a) =>
      double.tryParse(a.replaceAll(',', '')) ?? 0.0;

  String _formatAmount(double v) {
    if (v >= 1000) return v.toStringAsFixed(2);
    if (v >= 1) return v.toStringAsFixed(4);
    if (v >= 0.0001) return v.toStringAsFixed(6);
    if (v > 0) return v.toStringAsFixed(8);
    return '0';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom stopwatch painter
// Draws: outer circle, crown nub on top, two side buttons, sweeping hand
// ─────────────────────────────────────────────────────────────────────────────
class _StopwatchPainter extends CustomPainter {
  /// 0.0→1.0: one full revolution per second (drives the sweeping hand)
  final double handFraction;
  /// 1.0 = full (start), 0.0 = empty (end) — drives the draining pie fill
  final double fillFraction;
  final Color color;

  _StopwatchPainter({
    required this.handFraction,
    required this.fillFraction,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    // shift face centre down a touch so crown fits above
    final double cy = size.height / 2 + size.height * 0.06;
    final double r = size.width * 0.36;

    // ── Stroke paint (outline, crown, buttons, hand) ──────────────────────
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ── 1. Pie fill — drains from full to empty, top to clockwise ────────
    // Draw filled arc clipped to the circle.
    // fillFraction 1.0 = full circle, 0.0 = nothing.
    // The arc starts at -π/2 (12 o'clock) and sweeps clockwise.
    if (fillFraction > 0.001) {
      final pieFill = Paint()
        ..color = color.withOpacity(0.85)
        ..style = PaintingStyle.fill;

      if (fillFraction >= 0.999) {
        // Completely full — just draw a filled circle
        canvas.drawCircle(Offset(cx, cy), r - 0.5, pieFill);
      } else {
        // Draw pie slice: from -π/2 clockwise for fillFraction * 2π
        final path = Path()
          ..moveTo(cx, cy)
          ..arcTo(
            Rect.fromCircle(center: Offset(cx, cy), radius: r - 0.5),
            -pi / 2,                      // start: 12 o'clock
            fillFraction * 2 * pi,        // sweep clockwise
            false,
          )
          ..close();
        canvas.drawPath(path, pieFill);
      }
    }

    // ── 2. Outer circle outline (drawn on top of fill) ────────────────────
    canvas.drawCircle(Offset(cx, cy), r, stroke..strokeWidth = 1.3);

    // ── 3. Crown nub ──────────────────────────────────────────────────────
    final crownTop = cy - r - size.height * 0.15;
    canvas.drawLine(
      Offset(cx, cy - r),
      Offset(cx, crownTop),
      stroke..strokeWidth = 1.6,
    );
    canvas.drawLine(
      Offset(cx - size.width * 0.09, crownTop),
      Offset(cx + size.width * 0.09, crownTop),
      stroke..strokeWidth = 1.6,
    );

    // ── 4. Side buttons ───────────────────────────────────────────────────
    final bLen = size.width * 0.13;
    for (final a in [pi * 0.72, pi * 0.28]) {
      canvas.drawLine(
        Offset(cx + cos(a) * r,        cy - sin(a) * r),
        Offset(cx + cos(a) * (r + bLen), cy - sin(a) * (r + bLen)),
        stroke..strokeWidth = 1.5,
      );
    }

    // ── 5. Sweeping hand (drawn last so it's always visible) ─────────────
    final handAngle = -pi / 2 + handFraction * 2 * pi;
    final hx = cx + cos(handAngle) * r * 0.70;
    final hy = cy + sin(handAngle) * r * 0.70;

    // White hand so it contrasts against both filled and empty background
    canvas.drawLine(
      Offset(cx, cy),
      Offset(hx, hy),
      Paint()
        ..color = fillFraction > 0.15
            ? Colors.white.withOpacity(0.9)
            : color          // switch to dark when nearly empty
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Centre dot
    canvas.drawCircle(
      Offset(cx, cy), 1.3,
      Paint()..color = fillFraction > 0.15 ? Colors.white : color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_StopwatchPainter old) =>
      old.handFraction != handFraction || old.fillFraction != fillFraction;
}