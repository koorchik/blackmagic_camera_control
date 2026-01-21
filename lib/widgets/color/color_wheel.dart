import 'dart:math' as math;
import 'package:flutter/material.dart';

class ColorWheel extends StatefulWidget {
  const ColorWheel({
    super.key,
    required this.red,
    required this.green,
    required this.blue,
    required this.onChanged,
    required this.onChangeEnd,
    this.size = 200,
  });

  final double red;
  final double green;
  final double blue;
  final void Function(double red, double green, double blue) onChanged;
  final void Function(double red, double green, double blue) onChangeEnd;
  final double size;

  @override
  State<ColorWheel> createState() => _ColorWheelState();
}

class _ColorWheelState extends State<ColorWheel> {
  late double _red;
  late double _green;
  late double _blue;

  @override
  void initState() {
    super.initState();
    _red = widget.red;
    _green = widget.green;
    _blue = widget.blue;
  }

  @override
  void didUpdateWidget(ColorWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.red != widget.red ||
        oldWidget.green != widget.green ||
        oldWidget.blue != widget.blue) {
      _red = widget.red;
      _green = widget.green;
      _blue = widget.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.size / 2;
    final radius = center - 10;

    // Calculate position from RGB values
    final x = center + (_red - _blue) * radius * 0.5;
    final y = center - (_green - (_red + _blue) / 2) * radius * 0.5;

    return GestureDetector(
      onPanStart: (details) => _handlePan(details.localPosition, center, radius),
      onPanUpdate: (details) => _handlePan(details.localPosition, center, radius),
      onPanEnd: (_) => _handlePanEnd(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ColorWheelPainter(),
          child: Stack(
            children: [
              // Position indicator
              Positioned(
                left: x.clamp(0, widget.size - 20) - 10,
                top: y.clamp(0, widget.size - 20) - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePan(Offset position, double center, double radius) {
    // Convert position to color offsets
    final dx = (position.dx - center) / radius;
    final dy = (center - position.dy) / radius;

    // Clamp to wheel bounds
    final distance = math.sqrt(dx * dx + dy * dy);
    final clampedDx = distance > 1 ? dx / distance : dx;
    final clampedDy = distance > 1 ? dy / distance : dy;

    // Convert to RGB adjustments
    // Simple mapping: x affects red-blue, y affects green
    _red = (clampedDx * 0.5).clamp(-1.0, 1.0);
    _blue = (-clampedDx * 0.5).clamp(-1.0, 1.0);
    _green = (clampedDy * 0.5).clamp(-1.0, 1.0);

    setState(() {});
    widget.onChanged(_red, _green, _blue);
  }

  void _handlePanEnd() {
    widget.onChangeEnd(_red, _green, _blue);
  }
}

class _ColorWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw hue wheel
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 360; i++) {
      final startAngle = i * math.pi / 180;
      final sweepAngle = 1.5 * math.pi / 180;

      paint.shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          const Color(0xFFFF00FF), // Magenta
          Colors.red,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }

    // Draw gradient overlay for saturation
    final saturationPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, saturationPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw center crosshairs
    final crosshairPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
