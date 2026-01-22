import 'package:flutter/material.dart';

/// A horizontal bar that looks like a VU meter but behaves like a slider
/// for controlling audio input gain.
class GainBar extends StatefulWidget {
  const GainBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.minDb = -60.0,
    this.maxDb = 24.0,
    this.height = 32,
  });

  /// Current gain value (0.0 to 1.0 normalized)
  final double value;

  /// Called continuously while dragging
  final ValueChanged<double> onChanged;

  /// Called when drag ends
  final ValueChanged<double>? onChangeEnd;

  /// Minimum gain in dB (for label)
  final double minDb;

  /// Maximum gain in dB (for label)
  final double maxDb;

  /// Height of the bar
  final double height;

  @override
  State<GainBar> createState() => _GainBarState();
}

class _GainBarState extends State<GainBar> {
  double? _localValue;

  double get _displayValue => _localValue ?? widget.value;

  void _handleDragStart(DragStartDetails details) {
    _updateValue(details.localPosition);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _updateValue(details.localPosition);
  }

  void _handleDragEnd(DragEndDetails details) {
    final value = _localValue ?? widget.value;
    setState(() => _localValue = null);
    widget.onChangeEnd?.call(value);
  }

  void _handleTapUp(TapUpDetails details) {
    _updateValue(details.localPosition);
    widget.onChangeEnd?.call(_localValue ?? widget.value);
    setState(() => _localValue = null);
  }

  void _updateValue(Offset localPosition) {
    final box = context.findRenderObject() as RenderBox;
    final width = box.size.width;
    final value = (localPosition.dx / width).clamp(0.0, 1.0);
    setState(() => _localValue = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final dbRange = widget.maxDb - widget.minDb;
    final currentDb = widget.minDb + (_displayValue * dbRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Labels row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.minDb.toInt()} dB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${currentDb.toStringAsFixed(1)} dB',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              '${widget.maxDb.toInt()} dB',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Interactive bar
        GestureDetector(
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          onTapUp: _handleTapUp,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              height: widget.height,
              child: CustomPaint(
                painter: _GainBarPainter(
                  value: _displayValue,
                  isDragging: _localValue != null,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GainBarPainter extends CustomPainter {
  _GainBarPainter({
    required this.value,
    required this.isDragging,
  });

  final double value;
  final bool isDragging;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    // Draw background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, backgroundPaint);

    // Draw filled portion with gradient
    if (value > 0) {
      final filledWidth = size.width * value.clamp(0.0, 1.0);

      // Create gradient from green to yellow to red
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Colors.green,
          Colors.green,
          Colors.lightGreen,
          Colors.yellow,
          Colors.orange,
          Colors.red,
        ],
        stops: const [0.0, 0.5, 0.65, 0.75, 0.85, 1.0],
      );

      final fillPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(0, 0, size.width, size.height),
        )
        ..style = PaintingStyle.fill;

      // Clip to filled area
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, filledWidth, size.height),
        const Radius.circular(6),
      ));
      canvas.drawRRect(bgRect, fillPaint);
      canvas.restore();

      // Draw handle/thumb indicator
      final handleX = filledWidth.clamp(8.0, size.width - 8.0);
      final handlePaint = Paint()
        ..color = isDragging ? Colors.white : Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;

      // Draw vertical line as handle
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(handleX, size.height / 2),
            width: 4,
            height: size.height - 8,
          ),
          const Radius.circular(2),
        ),
        handlePaint,
      );
    }

    // Draw scale marks
    _drawScaleMarks(canvas, size);
  }

  void _drawScaleMarks(Canvas canvas, Size size) {
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw marks at 0%, 25%, 50%, 75%, 100%
    for (var i = 0; i <= 4; i++) {
      final x = size.width * (i / 4);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, 4),
        markPaint,
      );
      canvas.drawLine(
        Offset(x, size.height - 4),
        Offset(x, size.height),
        markPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GainBarPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.isDragging != isDragging;
  }
}
