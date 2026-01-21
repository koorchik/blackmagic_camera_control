import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return _buildWideLayout(cameraState, colorCorrection);
        }
        return _buildNarrowLayout(cameraState, colorCorrection);
      },
    );
  }

  Widget _buildNarrowLayout(
    CameraStateProvider cameraState,
    colorCorrection,
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
          _buildResetButton(cameraState, colorCorrection),
        ],
      ),
    );
  }

  Widget _buildWideLayout(
    CameraStateProvider cameraState,
    colorCorrection,
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
            ],
          ),
          const SizedBox(height: 16),
          _buildResetButton(cameraState, colorCorrection),
        ],
      ),
    );
  }

  Widget _buildResetButton(CameraStateProvider cameraState, colorCorrection) {
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
