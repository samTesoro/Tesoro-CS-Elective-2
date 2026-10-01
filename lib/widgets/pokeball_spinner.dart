import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class PokeballSpinner extends StatefulWidget {
  final double size;

  const PokeballSpinner({super.key, this.size = 72});

  @override
  State<PokeballSpinner> createState() => _PokeballSpinnerState();
}

class _PokeballSpinnerState extends State<PokeballSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _PokeballPainter(),
      ),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final stroke = size.width * 0.07;
    final innerRadius = radius - stroke / 2;
    final ballRect = Rect.fromCircle(center: center, radius: innerRadius);

    final fill = Paint()..style = PaintingStyle.fill;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = pixelBorderColor;

    // Top (red) and bottom (white) halves.
    canvas.drawArc(ballRect, math.pi, math.pi, true, fill..color = mainRed);
    canvas.drawArc(ballRect, 0, math.pi, true, fill..color = Colors.white);

    // Middle band and outer ring.
    canvas.drawLine(
      Offset(center.dx - innerRadius, center.dy),
      Offset(center.dx + innerRadius, center.dy),
      outline,
    );
    canvas.drawCircle(center, innerRadius, outline);

    // Center button.
    final buttonRadius = radius * 0.28;
    canvas.drawCircle(center, buttonRadius, fill..color = Colors.white);
    canvas.drawCircle(center, buttonRadius, outline);
    canvas.drawCircle(
      center,
      buttonRadius * 0.45,
      outline..strokeWidth = stroke * 0.6,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
