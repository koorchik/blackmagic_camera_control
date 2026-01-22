import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/continuous_slider_control.dart';

class IrisControl extends StatelessWidget {
  const IrisControl({super.key});

  // Standard f-stop scale (full stops)
  static const List<double> _fStops = [1.4, 2.0, 2.8, 4.0, 5.6, 8.0, 11, 16, 22];

  static String _getApertureDisplay(double normalized) {
    final index =
        (normalized * (_fStops.length - 1)).round().clamp(0, _fStops.length - 1);
    final fStop = _fStops[index];
    // Format nicely: show decimal only if needed
    return fStop == fStop.roundToDouble() ? 'f/${fStop.toInt()}' : 'f/$fStop';
  }

  static List<String> _getFStopLabels() {
    return _fStops.map((fStop) {
      return fStop == fStop.roundToDouble() ? '${fStop.toInt()}' : '$fStop';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return ContinuousSliderControl(
      title: 'IRIS',
      value: cameraState.lens.iris,
      onChanged: cameraState.setIrisDebounced,
      onChangeEnd: cameraState.setIrisFinal,
      formatValue: _getApertureDisplay,
      divisions: _fStops.length - 1,
      labels: _getFStopLabels(),
    );
  }
}
