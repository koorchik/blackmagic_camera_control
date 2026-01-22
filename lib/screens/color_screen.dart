import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/color_correction_state.dart';
import '../providers/camera_state_provider.dart';
import '../widgets/color/color_wheel_card.dart';

class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraStateProvider>().refreshColorCorrection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final colorCorrection = cameraState.colorCorrection;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width > 1000) {
          return _buildWideLayout(cameraState, colorCorrection);
        } else if (width > 600) {
          return _buildMediumLayout(cameraState, colorCorrection);
        }
        return _buildNarrowLayout(cameraState, colorCorrection);
      },
    );
  }

  /// Narrow layout: single column
  Widget _buildNarrowLayout(
    CameraStateProvider cameraState,
    ColorCorrectionState colorCorrection,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ColorWheelCard(
            title: 'LIFT',
            subtitle: 'Shadows',
            values: colorCorrection.lift,
            onChanged: cameraState.setColorLiftDebounced,
            onChangeEnd: cameraState.setColorLiftFinal,
          ),
          const SizedBox(height: 16),
          ColorWheelCard(
            title: 'GAMMA',
            subtitle: 'Midtones',
            values: colorCorrection.gamma,
            onChanged: cameraState.setColorGammaDebounced,
            onChangeEnd: cameraState.setColorGammaFinal,
          ),
          const SizedBox(height: 16),
          ColorWheelCard(
            title: 'GAIN',
            subtitle: 'Highlights',
            values: colorCorrection.gain,
            onChanged: cameraState.setColorGainDebounced,
            onChangeEnd: cameraState.setColorGainFinal,
            isGain: true,
          ),
          const SizedBox(height: 16),
          ColorWheelCard(
            title: 'OFFSET',
            subtitle: 'Blacks',
            values: colorCorrection.offset,
            onChanged: cameraState.setColorOffsetDebounced,
            onChangeEnd: cameraState.setColorOffsetFinal,
          ),
          const SizedBox(height: 16),
          _buildSlidersCard(cameraState, colorCorrection),
          const SizedBox(height: 16),
          _buildResetButton(cameraState, colorCorrection),
        ],
      ),
    );
  }

  /// Medium layout: 2x2 grid
  Widget _buildMediumLayout(
    CameraStateProvider cameraState,
    ColorCorrectionState colorCorrection,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ColorWheelCard(
                  title: 'LIFT',
                  subtitle: 'Shadows',
                  values: colorCorrection.lift,
                  onChanged: cameraState.setColorLiftDebounced,
                  onChangeEnd: cameraState.setColorLiftFinal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ColorWheelCard(
                  title: 'GAMMA',
                  subtitle: 'Midtones',
                  values: colorCorrection.gamma,
                  onChanged: cameraState.setColorGammaDebounced,
                  onChangeEnd: cameraState.setColorGammaFinal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ColorWheelCard(
                  title: 'GAIN',
                  subtitle: 'Highlights',
                  values: colorCorrection.gain,
                  onChanged: cameraState.setColorGainDebounced,
                  onChangeEnd: cameraState.setColorGainFinal,
                  isGain: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ColorWheelCard(
                  title: 'OFFSET',
                  subtitle: 'Blacks',
                  values: colorCorrection.offset,
                  onChanged: cameraState.setColorOffsetDebounced,
                  onChangeEnd: cameraState.setColorOffsetFinal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSlidersCard(cameraState, colorCorrection),
          const SizedBox(height: 16),
          _buildResetButton(cameraState, colorCorrection),
        ],
      ),
    );
  }

  /// Wide layout: 4 columns in a row
  Widget _buildWideLayout(
    CameraStateProvider cameraState,
    ColorCorrectionState colorCorrection,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ColorWheelCard(
                  title: 'LIFT',
                  subtitle: 'Shadows',
                  values: colorCorrection.lift,
                  onChanged: cameraState.setColorLiftDebounced,
                  onChangeEnd: cameraState.setColorLiftFinal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ColorWheelCard(
                  title: 'GAMMA',
                  subtitle: 'Midtones',
                  values: colorCorrection.gamma,
                  onChanged: cameraState.setColorGammaDebounced,
                  onChangeEnd: cameraState.setColorGammaFinal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ColorWheelCard(
                  title: 'GAIN',
                  subtitle: 'Highlights',
                  values: colorCorrection.gain,
                  onChanged: cameraState.setColorGainDebounced,
                  onChangeEnd: cameraState.setColorGainFinal,
                  isGain: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ColorWheelCard(
                  title: 'OFFSET',
                  subtitle: 'Blacks',
                  values: colorCorrection.offset,
                  onChanged: cameraState.setColorOffsetDebounced,
                  onChangeEnd: cameraState.setColorOffsetFinal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSlidersCard(cameraState, colorCorrection),
          const SizedBox(height: 16),
          _buildResetButton(cameraState, colorCorrection),
        ],
      ),
    );
  }

  Widget _buildSlidersCard(
    CameraStateProvider cameraState,
    ColorCorrectionState colorCorrection,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saturation slider (0.0 to 2.0, default 1.0)
            _buildSlider(
              label: 'Saturation',
              value: colorCorrection.saturation,
              min: 0.0,
              max: 2.0,
              defaultValue: 1.0,
              onChanged: cameraState.setColorSaturationDebounced,
              onChangeEnd: cameraState.setColorSaturation,
            ),
            const SizedBox(height: 12),
            // Hue slider (-1.0 to 1.0, default 0.0)
            _buildSlider(
              label: 'Hue',
              value: colorCorrection.hue,
              min: -1.0,
              max: 1.0,
              defaultValue: 0.0,
              onChanged: cameraState.setColorHueDebounced,
              onChangeEnd: cameraState.setColorHue,
            ),
            const SizedBox(height: 12),
            // Contrast slider (0.0 to 2.0, default 1.0)
            _buildSlider(
              label: 'Contrast',
              value: colorCorrection.contrast,
              min: 0.0,
              max: 2.0,
              defaultValue: 1.0,
              onChanged: cameraState.setColorContrastDebounced,
              onChangeEnd: cameraState.setColorContrast,
            ),
            const SizedBox(height: 12),
            // Luma Contribution slider (0.0 to 1.0, default 1.0)
            _buildSlider(
              label: 'Luma Mix',
              value: colorCorrection.lumaContribution,
              min: 0.0,
              max: 1.0,
              defaultValue: 1.0,
              onChanged: cameraState.setColorLumaContributionDebounced,
              onChangeEnd: cameraState.setColorLumaContribution,
              formatValue: (v) => '${(v * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required double defaultValue,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
    String Function(double)? formatValue,
  }) {
    return _ColorSlider(
      label: label,
      value: value,
      min: min,
      max: max,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      formatValue: formatValue,
    );
  }

  Widget _buildResetButton(
    CameraStateProvider cameraState,
    ColorCorrectionState colorCorrection,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed:
                  colorCorrection.isDefault ? null : cameraState.resetColorCorrection,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset All'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom slider widget that manages its own state during interaction
/// to prevent external state updates from interfering with dragging.
class _ColorSlider extends StatefulWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.onChanged,
    required this.onChangeEnd,
    this.formatValue,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double defaultValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;
  final String Function(double)? formatValue;

  @override
  State<_ColorSlider> createState() => _ColorSliderState();
}

class _ColorSliderState extends State<_ColorSlider> {
  double? _draggingValue;
  bool _isDragging = false;

  double get _displayValue => _draggingValue ?? widget.value;

  @override
  void didUpdateWidget(_ColorSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync external value when not dragging
    if (!_isDragging && oldWidget.value != widget.value) {
      _draggingValue = null;
    }
  }

  void _handleChangeStart(double value) {
    setState(() {
      _isDragging = true;
      _draggingValue = value;
    });
  }

  void _handleChange(double value) {
    setState(() {
      _draggingValue = value;
    });
    widget.onChanged(value);
  }

  void _handleChangeEnd(double value) {
    widget.onChangeEnd(value);
    setState(() {
      _isDragging = false;
      _draggingValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.formatValue?.call(_displayValue) ??
        _displayValue.toStringAsFixed(2);
    final isDefault = (_displayValue - widget.defaultValue).abs() < 0.001;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  displayValue,
                  style: TextStyle(
                    color: isDefault
                        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: isDefault ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                if (!isDefault)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => widget.onChangeEnd(widget.defaultValue),
                    tooltip: 'Reset to default',
                  ),
              ],
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _displayValue.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            onChangeStart: _handleChangeStart,
            onChanged: _handleChange,
            onChangeEnd: _handleChangeEnd,
          ),
        ),
      ],
    );
  }
}
