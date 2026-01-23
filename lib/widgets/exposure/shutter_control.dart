import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/discrete_slider_control.dart';

class ShutterControl extends StatelessWidget {
  const ShutterControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final video = cameraState.video;
    final isAuto = video.shutterAuto;
    final supportedShutterSpeeds = cameraState.capabilities.supportedShutterSpeeds;

    return DiscreteSliderControl<int>(
      title: 'SHUTTER',
      currentValue: video.shutterSpeed,
      values: supportedShutterSpeeds,
      enabled: !isAuto,
      onChanged: (speed) => cameraState.setShutterSpeedDebounced(speed),
      onChangeEnd: (speed) => cameraState.setShutterSpeedFinal(speed),
      formatValue: (speed) => '1/$speed',
      formatLabel: (speed) => '1/$speed',
      trailing: FilterChip(
        label: const Text('AUTO'),
        selected: isAuto,
        showCheckmark: false,
        onSelected: (_) {
          cameraState.toggleShutterAuto();
        },
      ),
    );
  }
}
