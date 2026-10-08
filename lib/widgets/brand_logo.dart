import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// โลโก้ PredictIQ: คลื่นสัญญาณความถี่ + ประแจ
class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ink, AppColors.inkSoft],
        ),
        border: Border.all(color: AppColors.signal.withAlpha(120), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.graphic_eq, size: size * 0.6, color: AppColors.signal),
          Positioned(
            right: size * 0.12,
            bottom: size * 0.12,
            child: Container(
              padding: EdgeInsets.all(size * 0.05),
              decoration: const BoxDecoration(
                  color: AppColors.ink, shape: BoxShape.circle),
              child: Icon(Icons.build, size: size * 0.26, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// เส้นคลื่นจางๆ เป็นพื้นหลังหัวหน้า Login
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final amp = 10.0 + i * 7;
      final y0 = size.height * (0.30 + i * 0.16);
      for (double x = 0; x <= size.width; x += 4) {
        final y = y0 +
            amp * math.sin(x / size.width * 2 * math.pi * (2 + i * 0.6) + i);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.signal.withAlpha(50 + i * 25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
