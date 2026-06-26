import 'package:flutter/material.dart';
import 'dart:math' as math;

class StarLogo extends StatefulWidget {
  const StarLogo({super.key});

  @override
  State<StarLogo> createState() => _StarLogoState();
}

class _StarLogoState extends State<StarLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Controls the continuous rotation of the orbital rings
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Controls the glowing pulsing effect of the central star
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use AnimatedBuilder to rebuild only the CustomPaint when animations update
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _SmartStarPainter(
            rotationValue: _rotationController.value,
            pulseValue: _pulseController.value,
          ),
        );
      },
    );
  }
}

class _SmartStarPainter extends CustomPainter {
  final double rotationValue;
  final double pulseValue;

  _SmartStarPainter({
    required this.rotationValue,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    _drawBackgroundGlow(canvas, center, maxRadius);
    _drawOrbitalRings(canvas, center, maxRadius);
    _drawCentralStar(canvas, center, maxRadius * 0.5);
  }

  // 1. Draws a soft, pulsing light behind the star
  void _drawBackgroundGlow(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF64FFDA).withOpacity(0.2 + (pulseValue * 0.3))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 + (pulseValue * 20));

    canvas.drawCircle(center, radius * 0.6, paint);
  }

  // 2. Draws the complex circuit-like rings and orbiting dots
  void _drawOrbitalRings(Canvas canvas, Offset center, double radius) {
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw three distinct orbits with different speeds and angles
    _drawSingleOrbit(canvas, center, radius * 0.7, ringPaint, nodePaint, rotationValue * 2 * math.pi, true);
    _drawSingleOrbit(canvas, center, radius * 0.85, ringPaint, nodePaint, -rotationValue * 3 * math.pi, false);
    _drawSingleOrbit(canvas, center, radius, ringPaint, nodePaint, rotationValue * 1.5 * math.pi + math.pi/2, true);
  }

  void _drawSingleOrbit(Canvas canvas, Offset center, double radius, Paint ringPaint, Paint nodePaint, double angleOffset, bool isElliptical) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Tilt the orbits to make it look 3D
    if (isElliptical) {
      canvas.scale(1.0, 0.4);
      canvas.rotate(math.pi / 4);
    } else {
      canvas.scale(1.0, 0.3);
      canvas.rotate(-math.pi / 6);
    }

    // Draw the circuit path
    canvas.drawCircle(Offset.zero, radius, ringPaint);

    // Calculate the position of the orbiting data node
    final nodeX = radius * math.cos(angleOffset);
    final nodeY = radius * math.sin(angleOffset);

    // Draw the data node (star/planet)
    canvas.drawCircle(Offset(nodeX, nodeY), 4.0, nodePaint);

    // Add a tiny glow to the node
    final nodeGlowPaint = Paint()
      ..color = Colors.blueAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(nodeX, nodeY), 6.0, nodeGlowPaint);

    canvas.restore();
  }

  // 3. Draws the complex multi-pointed inner star
  void _drawCentralStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    final int points = 8;

    // The star pulses slightly in size
    final currentOuterRadius = radius + (pulseValue * 10);
    final currentInnerRadius = radius * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final double currentRadius = i.isEven ? currentOuterRadius : currentInnerRadius;
      final double angle = i * math.pi / points;

      final double x = center.dx + currentRadius * math.cos(angle);
      final double y = center.dy + currentRadius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill paint for the star with a gradient
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFF81D4FA),
          const Color(0xFF0D47A1),
        ],
        stops: [0.1, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: currentOuterRadius));

    // Stroke paint to give it sharp edges
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SmartStarPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.pulseValue != pulseValue;
  }
}