import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/monitoring_state.dart';
import '../providers/camera_state_provider.dart';
import '../widgets/monitoring/display_selector.dart';
import '../widgets/monitoring/focus_assist_control.dart';
import '../widgets/monitoring/zebra_control.dart';
import '../widgets/monitoring/frame_guides_control.dart';
import '../widgets/monitoring/clean_feed_control.dart';
import '../widgets/monitoring/display_lut_control.dart';
import '../widgets/monitoring/program_feed_control.dart';
import '../widgets/monitoring/video_format_selector.dart';
import '../widgets/monitoring/codec_format_selector.dart';
import '../widgets/monitoring/color_bars_control.dart';
import '../widgets/monitoring/false_color_control.dart';
import '../widgets/monitoring/safe_area_control.dart';
import '../widgets/monitoring/frame_grids_control.dart';
import '../widgets/preset/preset_section.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraStateProvider>().refreshMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final monitoring = cameraState.monitoring;

    if (monitoring.availableDisplays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monitor_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Monitoring not available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This camera does not support the monitoring REST API.\n'
                'Monitoring controls require firmware 9.6+ and are only\n'
                'available on select cameras (e.g., Micro Studio Camera 4K G2).',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => cameraState.refreshMonitoring(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLeftColumn(monitoring)),
                const SizedBox(width: 16),
                Expanded(child: _buildRightColumn(monitoring)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDisplaySettings(monitoring),
              const SizedBox(height: 24),
              _buildCameraOutputSettings(),
              const SizedBox(height: 24),
              const PresetSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftColumn(MonitoringState monitoring) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DisplaySelector(),
        const SizedBox(height: 16),
        if (monitoring.currentDisplay != null) ...[
          const FocusAssistControl(),
          const SizedBox(height: 8),
          const ZebraControl(),
          const SizedBox(height: 8),
          const FalseColorControl(),
          const SizedBox(height: 8),
          const FrameGuidesControl(),
          const SizedBox(height: 8),
          const SafeAreaControl(),
          const SizedBox(height: 8),
          const FrameGridsControl(),
        ],
      ],
    );
  }

  Widget _buildRightColumn(MonitoringState monitoring) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (monitoring.currentDisplay != null) ...[
          const DisplayLutControl(),
          const SizedBox(height: 8),
          const CleanFeedControl(),
          const SizedBox(height: 16),
        ],
        const ColorBarsControl(),
        const SizedBox(height: 8),
        _buildCameraOutputSettings(),
        const SizedBox(height: 16),
        const PresetSection(),
      ],
    );
  }

  Widget _buildDisplaySettings(MonitoringState monitoring) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DisplaySelector(),
        const SizedBox(height: 16),
        if (monitoring.currentDisplay != null) ...[
          const FocusAssistControl(),
          const SizedBox(height: 8),
          const ZebraControl(),
          const SizedBox(height: 8),
          const FalseColorControl(),
          const SizedBox(height: 8),
          const FrameGuidesControl(),
          const SizedBox(height: 8),
          const SafeAreaControl(),
          const SizedBox(height: 8),
          const FrameGridsControl(),
          const SizedBox(height: 8),
          const DisplayLutControl(),
          const SizedBox(height: 8),
          const CleanFeedControl(),
          const SizedBox(height: 8),
          const ColorBarsControl(),
        ],
      ],
    );
  }

  Widget _buildCameraOutputSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Camera Output',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const ProgramFeedControl(),
        const SizedBox(height: 8),
        const VideoFormatSelector(),
        const SizedBox(height: 8),
        const CodecFormatSelector(),
      ],
    );
  }
}
