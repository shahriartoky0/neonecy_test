import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neonecy_test/core/config/app_sizes.dart';
import 'package:neonecy_test/core/design/app_colors.dart';

class SocialAuthButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const SocialAuthButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textGreyLight, width: 0.6),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(left: 0, child: icon),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simplified multi-color Google "G" logo, drawn without any image asset.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double strokeWidth = size.width * 0.22;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final Rect rect = Rect.fromCircle(radius: radius - strokeWidth / 2, center: center);

    paint.color = const Color(0xFF4285F4); // blue - right
    canvas.drawArc(rect, -0.35, 1.7, false, paint);

    paint.color = const Color(0xFF34A853); // green - bottom
    canvas.drawArc(rect, 1.35, 1.55, false, paint);

    paint.color = const Color(0xFFFBBC05); // yellow - left
    canvas.drawArc(rect, 2.9, 1.1, false, paint);

    paint.color = const Color(0xFFEA4335); // red - top
    canvas.drawArc(rect, 4.0, 1.6, false, paint);

    // horizontal bar of the "G"
    final Paint barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(radius, radius - strokeWidth / 2, radius - strokeWidth / 2, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Person + key icon approximating a "Passkey" glyph without a dedicated asset.
class PasskeyIcon extends StatelessWidget {
  final double size;

  const PasskeyIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const Stack(
        children: <Widget>[
          Icon(CupertinoIcons.person, color: AppColors.white),
          Positioned(
            right: -4,
            bottom: 6,
            child: RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.vpn_key, size: 14, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
