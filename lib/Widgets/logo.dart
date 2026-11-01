import 'package:flutter/material.dart';

class AlysarGraniteLogo extends StatelessWidget {
  final double width;
  final double height;

  const AlysarGraniteLogo({super.key, this.width = 320, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _AlysarLogoPainter()),
    );
  }
}

class _AlysarLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // خلفية الجرانيت
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(22),
    );

    paint.shader = const LinearGradient(
      colors: [Color(0xFF2B2B2B), Color(0xFF4A4A4A), Color(0xFF1A1A1A)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(bgRect, paint);

    // شكل بلاطة الجرانيت
    final tilePath = Path()
      ..moveTo(size.width * 0.10, size.height * 0.25)
      ..lineTo(size.width * 0.20, size.height * 0.25)
      ..lineTo(size.width * 0.26, size.height * 0.78)
      ..lineTo(size.width * 0.16, size.height * 0.78)
      ..close();

    paint.shader = const LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF5D67B), Color(0xFFB8860B)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(tilePath, paint);

    // لمعة على البلاطة
    final shinePath = Path()
      ..moveTo(size.width * 0.20, size.height * 0.25)
      ..lineTo(size.width * 0.25, size.height * 0.25)
      ..lineTo(size.width * 0.31, size.height * 0.78)
      ..lineTo(size.width * 0.26, size.height * 0.78)
      ..close();

    paint.shader = null;
    paint.color = Colors.white.withValues(alpha: 0.12);
    canvas.drawPath(shinePath, paint);

    // اسم الشركة
    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    textPainter.text = const TextSpan(
      text: 'Al Yousr',
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );

    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, Offset(size.width * 0.36, size.height * 0.22));

    // كلمة للجرانيت
    final subTextPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    subTextPainter.text = const TextSpan(
      text: 'Marble And Aranite',
      style: TextStyle(
        color: Color.fromARGB(255, 244, 201, 85),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );

    subTextPainter.layout(maxWidth: size.width);
    subTextPainter.paint(canvas, Offset(size.width * 0.36, size.height * 0.55));

    // خط ذهبي سفلي
    paint.shader = const LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFF5D67B), Color(0xFFB8860B)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.36,
        size.height * 0.80,
        size.width * 0.38,
        3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
