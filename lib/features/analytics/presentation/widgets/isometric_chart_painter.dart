import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a 3-block isometric stacked bar chart matching the reference design.
///
/// Each bar has three stacked 3D cubes with a small gap between them:
///   - Bottom  : Indigo / blue-purple  (1L → 1M range)
///   - Middle  : Violet / magenta-purple (1M → 5M range)
///   - Top     : Light cyan / ice-blue  (5M → 50M range)
///
/// The _drawCube helper constructs the left-face, right-face, and top-face
/// paths of each isometric box using a 30° (pi/6) projection angle.
class IsometricChartPainter extends CustomPainter {
  // Chart data: values grow progressively to match the reference proportions.
  final List<Map<String, dynamic>> data = [
    {'year': '2018', 'indigo': 70,  'violet': 60,  'cyan': 70},
    {'year': '2019', 'indigo': 90,  'violet': 75,  'cyan': 110},
    {'year': '2020', 'indigo': 110, 'violet': 90,  'cyan': 160},
  ];

  // Gap in pixels inserted between each stacked block
  static const double _blockGap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawLabels(canvas, size);
    _drawIsometricBars(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x22BDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double stepY = size.height / 6;
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(50, size.height - stepY * i - 40),
        Offset(size.width, size.height - stepY * i - 40),
        paint,
      );
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labels = ['', '1L', '1M', '5M', '10M', '50M'];
    final double stepY = size.height / 6;

    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(8, size.height - stepY * i - 40 - textPainter.height / 2),
      );
    }
  }

  void _drawIsometricBars(Canvas canvas, Size size) {
    const double angle = pi / 6; // 30° isometric projection
    final double cosA = cos(angle);
    final double sinA = sin(angle);

    final double startY = size.height - 40;
    final double barWidth = 22; // Even smaller blocks
    final double spacing = 65; // Tighter horizontal gap
    // Center the 3 bars within the graph area (graph width is size.width - 50)
    final double graphCenterX = 50 + (size.width - 50) / 2;
    final double startX = graphCenterX - spacing; // 1st bar on left, 2nd in middle, 3rd on right

    // ── Pre-draw single large oval platform (ground) ─────────────────────
    final double firstX = startX;
    final double lastX = startX + (data.length - 1) * spacing;
    final double centerX = (firstX + lastX) / 2;

    final Paint platformPaint = Paint()
      ..color = const Color(0xFFE2E8F0); // Solid light gray floor matching image
    
    // Additional soft shadow under the platform
    final Paint shadowPaint = Paint()
      ..color = const Color(0x33B0BEC5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final Rect platformRect = Rect.fromCenter(
      center: Offset(centerX, startY),
      width: (lastX - firstX) + barWidth * 3.5, // Reduced oval width
      height: barWidth * 2.2, // Reduced oval height
    );

    canvas.drawOval(platformRect.translate(0, 4), shadowPaint);
    canvas.drawOval(platformRect, platformPaint);

    // ── Indigo (Bottom block) ──────────────────────────────────────────────
    final Paint indigoLeft  = Paint()..color = const Color(0xFF5B69AE); // dark
    final Paint indigoRight = Paint()..color = const Color(0xFF7586D3); // mid
    final Paint indigoTop   = Paint()..color = const Color(0xFF90A1ED); // light

    // ── Violet (Middle block) ──────────────────────────────────────────────
    final Paint violetLeft  = Paint()..color = const Color(0xFF8640A0); // dark
    final Paint violetRight = Paint()..color = const Color(0xFFA55CD2); // mid
    final Paint violetTop   = Paint()..color = const Color(0xFFBC75E8); // light

    // ── Cyan (Top block) ──────────────────────────────────────────────────
    final Paint cyanLeft  = Paint()..color = const Color(0xFF7CB8CC); // dark
    final Paint cyanRight = Paint()..color = const Color(0xFF9AE0F1); // mid
    final Paint cyanTop   = Paint()..color = const Color(0xFFC8F5FE); // light

    final double maxVal = 550.0; // Increased maxVal to shrink height scale
    final double scaleY = (size.height - 100) / maxVal;

    for (int i = 0; i < data.length; i++) {
      final double xPos = startX + (i * spacing);

      final double indigoH = data[i]['indigo'] * scaleY;
      final double violetH = data[i]['violet'] * scaleY;
      final double cyanH   = data[i]['cyan']   * scaleY;

      // Bottom block (Indigo) — sits on the baseline
      _drawCube(canvas, Offset(xPos, startY), barWidth, indigoH,
          indigoLeft, indigoRight, indigoTop, cosA, sinA);

      // Middle block (Violet) — offset above indigo + gap
      _drawCube(canvas, Offset(xPos, startY - indigoH - _blockGap), barWidth, violetH,
          violetLeft, violetRight, violetTop, cosA, sinA);

      // Top block (Cyan) — offset above violet + gap
      _drawCube(canvas, Offset(xPos, startY - indigoH - violetH - _blockGap * 2), barWidth, cyanH,
          cyanLeft, cyanRight, cyanTop, cosA, sinA);

      // Year label below baseline
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i]['year'],
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, startY + 22)); // Pushed below the base oval
    }
  }

  /// Draws one isometric cube.
  ///
  /// [baseCenter] is the bottom-front vertex of the cube.
  /// [size]       controls the width of the cube's diamond footprint.
  /// [height]     is the vertical pixel height of the cube.
  /// The three Paint arguments control the left face, right face, and top face
  /// colours to simulate directional lighting.
  void _drawCube(
    Canvas canvas,
    Offset baseCenter,
    double size,
    double height,
    Paint leftPaint,
    Paint rightPaint,
    Paint topPaint,
    double cosA,
    double sinA,
  ) {
    final double dx = size * cosA;
    final double dy = size * sinA;

    // Diamond base vertices
    final Offset p0 = baseCenter;                          // front
    final Offset p1 = Offset(p0.dx - dx, p0.dy - dy);    // left
    final Offset p2 = Offset(p0.dx + dx, p0.dy - dy);    // right
    final Offset p3 = Offset(p0.dx, p0.dy - 2 * dy);     // back

    // Top vertices
    final Offset t0 = Offset(p0.dx, p0.dy - height);
    final Offset t1 = Offset(p1.dx, p1.dy - height);
    final Offset t2 = Offset(p2.dx, p2.dy - height);
    final Offset t3 = Offset(p3.dx, p3.dy - height);

    // Left face
    canvas.drawPath(
      Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)
            ..lineTo(t1.dx, t1.dy)..lineTo(t0.dx, t0.dy)..close(),
      leftPaint,
    );

    // Right face
    canvas.drawPath(
      Path()..moveTo(p0.dx, p0.dy)..lineTo(p2.dx, p2.dy)
            ..lineTo(t2.dx, t2.dy)..lineTo(t0.dx, t0.dy)..close(),
      rightPaint,
    );

    // Top face
    canvas.drawPath(
      Path()..moveTo(t0.dx, t0.dy)..lineTo(t1.dx, t1.dy)
            ..lineTo(t3.dx, t3.dy)..lineTo(t2.dx, t2.dy)..close(),
      topPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

