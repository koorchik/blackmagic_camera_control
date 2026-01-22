import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/continuous_slider_control.dart';

class ZoomControl extends StatelessWidget {
  const ZoomControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return ContinuousSliderControl(
      title: 'ZOOM',
      value: cameraState.lens.zoom,
      onChanged: cameraState.setZoomDebounced,
      onChangeEnd: cameraState.setZoomFinal,
      formatValue: (value) => '${(value * 100).toStringAsFixed(0)}%',
      leadingIcon: Icons.zoom_out,
      trailingIcon: Icons.zoom_in,
    );
  }
}
