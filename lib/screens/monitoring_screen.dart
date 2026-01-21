import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_state_provider.dart';
import '../widgets/monitoring/display_selector.dart';
import '../widgets/monitoring/focus_assist_control.dart';
import '../widgets/monitoring/zebra_control.dart';
import '../widgets/monitoring/frame_guides_control.dart';

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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No displays available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DisplaySelector(),
          const SizedBox(height: 16),
          if (monitoring.currentDisplay != null) ...[
            const FocusAssistControl(),
            const SizedBox(height: 8),
            const ZebraControl(),
            const SizedBox(height: 8),
            const FrameGuidesControl(),
          ],
        ],
      ),
    );
  }
}
