import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/monitoring_state.dart';
import '../providers/camera_state_provider.dart';
import '../utils/constants.dart';
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
              Spacing.verticalLg,
              const Text(
                'Monitoring not available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacing.verticalSm,
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
        final isWide = constraints.maxWidth > Breakpoints.medium;

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
        Spacing.verticalLg,
        if (monitoring.currentDisplay != null) ...[
          const FocusAssistControl(),
          Spacing.verticalSm,
          const ZebraControl(),
          Spacing.verticalSm,
          const FalseColorControl(),
          Spacing.verticalSm,
          const FrameGuidesControl(),
          Spacing.verticalSm,
          const SafeAreaControl(),
          Spacing.verticalSm,
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
          Spacing.verticalSm,
          const CleanFeedControl(),
          Spacing.verticalLg,
        ],
        const ColorBarsControl(),
        Spacing.verticalSm,
        _buildCameraOutputSettings(),
        Spacing.verticalLg,
        const PresetSection(),
      ],
    );
  }

  Widget _buildDisplaySettings(MonitoringState monitoring) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DisplaySelector(),
        Spacing.verticalLg,
        if (monitoring.currentDisplay != null) ...[
          const FocusAssistControl(),
          Spacing.verticalSm,
          const ZebraControl(),
          Spacing.verticalSm,
          const FalseColorControl(),
          Spacing.verticalSm,
          const FrameGuidesControl(),
          Spacing.verticalSm,
          const SafeAreaControl(),
          Spacing.verticalSm,
          const FrameGridsControl(),
          Spacing.verticalSm,
          const DisplayLutControl(),
          Spacing.verticalSm,
          const CleanFeedControl(),
          Spacing.verticalSm,
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
          padding: EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
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
        Spacing.verticalSm,
        const ProgramFeedControl(),
        Spacing.verticalSm,
        const VideoFormatSelector(),
        Spacing.verticalSm,
        const CodecFormatSelector(),
      ],
    );
  }
}
