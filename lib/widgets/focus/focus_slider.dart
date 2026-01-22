import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/continuous_slider_control.dart';

class FocusSlider extends StatelessWidget {
  const FocusSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return ContinuousSliderControl(
      title: 'FOCUS',
      value: cameraState.lens.focus,
      onChanged: cameraState.setFocusDebounced,
      onChangeEnd: cameraState.setFocusFinal,
      formatValue: (value) => '${(value * 100).toStringAsFixed(0)}%',
      leadingLabel: 'Near',
      trailingLabel: 'Far',
      showCard: false,
    );
  }
}
