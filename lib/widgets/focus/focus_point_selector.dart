import 'package:flutter/material.dart';

/// A touch pad widget for selecting focus position in the camera frame.
/// Displays a 16:9 aspect ratio frame with rule-of-thirds grid and focus bracket.
class FocusPointSelector extends StatefulWidget {
  const FocusPointSelector({
    super.key,
    required this.onPositionSelected,
    this.isLoading = false,
  });

  /// Callback when user taps or drags to select a focus position.
  /// [x] and [y] are normalized coordinates (0.0-1.0).
  final void Function(double x, double y) onPositionSelected;

  /// Whether autofocus is currently in progress.
  final bool isLoading;

  @override
  State<FocusPointSelector> createState() => _FocusPointSelectorState();
}

class _FocusPointSelectorState extends State<FocusPointSelector>
    with SingleTickerProviderStateMixin {
  // Current selected position (normalized 0.0-1.0)
  double _x = 0.5;
  double _y = 0.5;

  // Animation controller for the pulse effect during autofocus
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FocusPointSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapOrDrag(Offset localPosition, Size size) {
    // Convert to normalized coordinates (0.0-1.0)
    final x = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final y = (localPosition.dy / size.height).clamp(0.0, 1.0);

    setState(() {
      _x = x;
      _y = y;
    });

    widget.onPositionSelected(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Frame selector with 16:9 aspect ratio
        AspectRatio(
          aspectRatio: 16 / 9,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);

              return GestureDetector(
                onTapDown: (details) => _handleTapOrDrag(details.localPosition, size),
                onPanUpdate: (details) => _handleTapOrDrag(details.localPosition, size),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CustomPaint(
                      painter: _FocusFramePainter(
                        focusX: _x,
                        focusY: _y,
                        isLoading: widget.isLoading,
                        pulseScale: _pulseAnimation.value,
                        gridColor: Colors.white24,
                        bracketColor: widget.isLoading
                            ? theme.colorScheme.primary
                            : Colors.white,
                      ),
                      child: widget.isLoading
                          ? AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _FocusFramePainter(
                                    focusX: _x,
                                    focusY: _y,
                                    isLoading: true,
                                    pulseScale: _pulseAnimation.value,
                                    gridColor: Colors.white24,
                                    bracketColor: theme.colorScheme.primary,
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Center Focus button
        OutlinedButton.icon(
          onPressed: widget.isLoading
              ? null
              : () {
                  setState(() {
                    _x = 0.5;
                    _y = 0.5;
                  });
                  widget.onPositionSelected(0.5, 0.5);
                },
          icon: widget.isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : const Icon(Icons.center_focus_strong, size: 18),
          label: Text(widget.isLoading ? 'Focusing...' : 'Center Focus'),
        ),
      ],
    );
  }
}

/// Custom painter for the focus frame with grid and bracket indicator.
class _FocusFramePainter extends CustomPainter {
  _FocusFramePainter({
    required this.focusX,
    required this.focusY,
    required this.isLoading,
    required this.pulseScale,
    required this.gridColor,
    required this.bracketColor,
  });

  final double focusX;
  final double focusY;
  final bool isLoading;
  final double pulseScale;
  final Color gridColor;
  final Color bracketColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw rule-of-thirds grid
    _drawGrid(canvas, size);

    // Draw focus bracket at selected position
    _drawFocusBracket(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical lines (thirds)
    final thirdWidth = size.width / 3;
    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      paint,
    );

    // Horizontal lines (thirds)
    final thirdHeight = size.height / 3;
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      paint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
      paint,
    );
  }

  void _drawFocusBracket(Canvas canvas, Size size) {
    final centerX = focusX * size.width;
    final centerY = focusY * size.height;

    // Bracket size (scaled for animation during loading)
    final baseSize = size.width * 0.08;
    final bracketSize = isLoading ? baseSize * pulseScale : baseSize;
    final cornerLength = bracketSize * 0.4;
    final strokeWidth = 2.0;

    final paint = Paint()
      ..color = bracketColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calculate bracket corners
    final left = centerX - bracketSize / 2;
    final right = centerX + bracketSize / 2;
    final top = centerY - bracketSize / 2;
    final bottom = centerY + bracketSize / 2;

    // Draw four corner brackets (professional camera style)
    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      paint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right - cornerLength, top),
      Offset(right, top),
      paint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom - cornerLength),
      Offset(left, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerLength, bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLength),
      paint,
    );

    // Draw small center crosshair
    final crosshairSize = bracketSize * 0.15;
    final crosshairPaint = Paint()
      ..color = bracketColor.withValues(alpha: 0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX - crosshairSize, centerY),
      Offset(centerX + crosshairSize, centerY),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - crosshairSize),
      Offset(centerX, centerY + crosshairSize),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusFramePainter oldDelegate) {
    return oldDelegate.focusX != focusX ||
        oldDelegate.focusY != focusY ||
        oldDelegate.isLoading != isLoading ||
        oldDelegate.pulseScale != pulseScale ||
        oldDelegate.bracketColor != bracketColor;
  }
}
