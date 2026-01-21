import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/discrete_slider_control.dart';

class IsoSelector extends StatelessWidget {
  const IsoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentIso = cameraState.video.iso;
    final supportedISOs = cameraState.capabilities.supportedISOs;

    return DiscreteSliderControl<int>(
      title: 'ISO',
      currentValue: currentIso,
      values: supportedISOs,
      onChanged: (iso) => cameraState.setIso(iso),
      formatValue: (iso) => '$iso',
      formatLabel: (iso) => '$iso',
    );
  }
}
