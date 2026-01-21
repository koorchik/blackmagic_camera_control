import 'package:flutter/material.dart';

class VuMeter extends StatelessWidget {
  const VuMeter({
    super.key,
    required this.level,
    this.width = 24,
    this.height = 200,
    this.horizontal = false,
  });

  final double level;
  final double width;
  final double height;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: horizontal ? height : width,
      height: horizontal ? width : height,
      child: CustomPaint(
        painter: _VuMeterPainter(
          level: level.clamp(0.0, 1.0),
          horizontal: horizontal,
        ),
      ),
    );
  }
}

class _VuMeterPainter extends CustomPainter {
  _VuMeterPainter({
    required this.level,
    required this.horizontal,
  });

  final double level;
  final bool horizontal;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(4),
      ),
      backgroundPaint,
    );

    // Draw level bar
    if (level > 0) {
      final levelHeight = horizontal ? size.width * level : size.height * level;

      // Create gradient
      final gradient = LinearGradient(
        begin: horizontal ? Alignment.centerLeft : Alignment.bottomCenter,
        end: horizontal ? Alignment.centerRight : Alignment.topCenter,
        colors: const [
          Colors.green,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ],
        stops: const [0.0, 0.6, 0.75, 0.9, 1.0],
      );

      final rect = horizontal
          ? Rect.fromLTWH(0, 0, levelHeight, size.height)
          : Rect.fromLTWH(
              0, size.height - levelHeight, size.width, levelHeight);

      final levelPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        levelPaint,
      );
    }

    // Draw scale marks
    _drawScaleMarks(canvas, size);
  }

  void _drawScaleMarks(Canvas canvas, Size size) {
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // dB marks at -48, -24, -12, -6, 0
    final marks = [0.0, 0.25, 0.5, 0.75, 1.0]; // Corresponding to dB values

    for (final mark in marks) {
      final pos = horizontal ? size.width * mark : size.height * (1 - mark);

      if (horizontal) {
        canvas.drawLine(
          Offset(pos, 0),
          Offset(pos, 4),
          markPaint,
        );
        canvas.drawLine(
          Offset(pos, size.height - 4),
          Offset(pos, size.height),
          markPaint,
        );
      } else {
        canvas.drawLine(
          Offset(0, pos),
          Offset(4, pos),
          markPaint,
        );
        canvas.drawLine(
          Offset(size.width - 4, pos),
          Offset(size.width, pos),
          markPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VuMeterPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.horizontal != horizontal;
  }
}

class VuMeterWithLabels extends StatelessWidget {
  const VuMeterWithLabels({
    super.key,
    required this.level,
    this.width = 24,
    this.height = 200,
    this.horizontal = false,
  });

  final double level;
  final double width;
  final double height;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final labels = ['0', '-6', '-12', '-24', '-48'];

    if (horizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.reversed
                .map((l) => Text(l, style: const TextStyle(fontSize: 10)))
                .toList(),
          ),
          const SizedBox(height: 4),
          VuMeter(
            level: level,
            width: width,
            height: height,
            horizontal: true,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VuMeter(
          level: level,
          width: width,
          height: height,
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((l) => Text(l, style: const TextStyle(fontSize: 10)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
