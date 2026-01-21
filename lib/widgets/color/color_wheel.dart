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
    this.isGain = false,
  });

  final double red;
  final double green;
  final double blue;
  final void Function(double red, double green, double blue) onChanged;
  final void Function(double red, double green, double blue) onChangeEnd;
  final double size;
  /// If true, values are in Gain mode (0.0-2.0 range with 1.0 as center).
  /// If false, values are in Lift/Gamma mode (-1.0 to 1.0 range with 0.0 as center).
  final bool isGain;

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

    // For Gain mode, offset values so 1.0 becomes center (0)
    // For Lift/Gamma, 0.0 is already center
    final offset = widget.isGain ? 1.0 : 0.0;
    final normalizedRed = _red - offset;
    final normalizedGreen = _green - offset;
    final normalizedBlue = _blue - offset;

    // Calculate position from RGB values
    // dx: red increases right, blue increases left, so dx = (red - blue) / 2
    // dy: green increases up, the (red+blue)/2 term compensates for slider adjustments
    var dx = (normalizedRed - normalizedBlue) / 2;
    var dy = -(normalizedGreen - (normalizedRed + normalizedBlue) / 2);

    // Constrain to circle
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance > 1) {
      dx = dx / distance;
      dy = dy / distance;
    }

    final x = center + dx * radius;
    final y = center + dy * radius;

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
                left: x - 10,
                top: y - 10,
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

    // For Gain mode, offset values so center produces 1.0
    // For Lift/Gamma, center produces 0.0
    final offset = widget.isGain ? 1.0 : 0.0;
    final minVal = widget.isGain ? 0.0 : -1.0;
    final maxVal = widget.isGain ? 2.0 : 1.0;

    // Convert to RGB adjustments
    // Simple mapping: x affects red-blue, y affects green
    _red = (clampedDx + offset).clamp(minVal, maxVal);
    _blue = (-clampedDx + offset).clamp(minVal, maxVal);
    _green = (clampedDy + offset).clamp(minVal, maxVal);

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
