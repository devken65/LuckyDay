import 'package:flutter/material.dart';

/// Lucky Day 로고 위젯
///
/// 네잎클로버 형태의 녹색 로고에 "Lucky Day!" 텍스트를 표시합니다.
class LuckyDayLogo extends StatelessWidget {
  /// [LuckyDayLogo] 생성자
  const LuckyDayLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F1),
        shape: BoxShape.circle,
        boxShadow: [
          // 외부 그림자 (네오모피즘 효과)
          BoxShadow(
            color: const Color(0xFFD9D4CE),
            offset: const Offset(10, 10),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-10, -10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 세잎클로버 디자인
          CustomPaint(
            size: const Size(160, 160),
            painter: _CloverPainter(),
          ),
          // 텍스트
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lucky',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    height: 1.2,
                    color: Color(0xFF2B2B2B),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Day!',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    height: 1.2,
                    color: Color(0xFF2B2B2B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 네잎클로버 모양을 그리는 CustomPainter
class _CloverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBFE6A8)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final center = Offset(size.width / 2, size.height / 2);

    // 세잎클로버의 각 잎 (하트 모양) - 상, 좌, 우 3개만 그림
    // 상단 잎
    _drawHeartLeaf(canvas, paint, shadowPaint, center, 0);
    // 좌측 하단 잎
    _drawHeartLeaf(canvas, paint, shadowPaint, center, 120);
    // 우측 하단 잎
    _drawHeartLeaf(canvas, paint, shadowPaint, center, -120);

    // 중앙 원형 (클로버 중심)
    canvas.drawCircle(center, 9, shadowPaint);
    canvas.drawCircle(center, 9, paint);

    // 줄기
    final stemPaint = Paint()
      ..color = const Color(0xFFBFE6A8)
      ..style = PaintingStyle.fill;

    final stemPath = Path()
      ..moveTo(center.dx - 3, center.dy + 8)
      ..quadraticBezierTo(
        center.dx + 4,
        center.dy + 35,
        center.dx + 2,
        center.dy + 60,
      )
      ..lineTo(center.dx - 2, center.dy + 60)
      ..quadraticBezierTo(
        center.dx - 4,
        center.dy + 35,
        center.dx + 3,
        center.dy + 8,
      )
      ..close();

    canvas.drawPath(stemPath, shadowPaint);
    canvas.drawPath(stemPath, stemPaint);
  }

  void _drawHeartLeaf(Canvas canvas, Paint paint, Paint shadowPaint,
      Offset center, double angleDegrees) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleDegrees * 3.14159 / 180);

    final path = Path();
    const leafWidth = 24.0;
    const leafHeight = 28.0;

    // 하트 모양의 잎 그리기
    path.moveTo(0, -12);

    // 왼쪽 상단 곡선
    path.cubicTo(
      -leafWidth / 2,
      -leafHeight,
      -leafWidth,
      -leafHeight * 0.6,
      -leafWidth * 0.7,
      -8,
    );

    // 왼쪽 하단
    path.quadraticBezierTo(-leafWidth * 0.3, 0, 0, 8);

    // 오른쪽 하단
    path.quadraticBezierTo(leafWidth * 0.3, 0, leafWidth * 0.7, -8);

    // 오른쪽 상단 곡선
    path.cubicTo(
      leafWidth,
      -leafHeight * 0.6,
      leafWidth / 2,
      -leafHeight,
      0,
      -12,
    );

    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
