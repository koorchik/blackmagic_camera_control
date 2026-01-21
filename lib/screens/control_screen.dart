import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_connection_provider.dart';
import '../providers/camera_state_provider.dart';
import '../widgets/focus/focus_slider.dart';
import '../widgets/focus/autofocus_button.dart';
import '../widgets/exposure/iso_selector.dart';
import '../widgets/exposure/shutter_control.dart';
import '../widgets/exposure/white_balance_control.dart';
import '../widgets/lens/iris_control.dart';
import '../widgets/lens/zoom_control.dart';
import '../widgets/transport/record_button.dart';
import '../widgets/transport/timecode_display.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  void initState() {
    super.initState();
    // Defer initialization to after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCameraState();
    });
  }

  void _initializeCameraState() {
    final connection = context.read<CameraConnectionProvider>();
    final cameraState = context.read<CameraStateProvider>();
    cameraState.initialize(connection.cameraService);
  }

  Future<void> _disconnect() async {
    final cameraState = context.read<CameraStateProvider>();
    cameraState.initialize(null);
    await context.read<CameraConnectionProvider>().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final connection = context.watch<CameraConnectionProvider>();
    final cameraState = context.watch<CameraStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(connection.cameraIp),
        actions: [
          if (cameraState.isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cameraState.isLoading ? null : cameraState.refresh,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.link_off),
            onPressed: _disconnect,
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          if (isWide) {
            return _buildWideLayout();
          }
          return _buildNarrowLayout();
        },
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFocusCard(),
          const SizedBox(height: 16),
          const IrisControl(),
          const ZoomControl(),
          const IsoSelector(),
          const ShutterControl(),
          const WhiteBalanceControl(),
          const SizedBox(height: 16),
          _buildTransportCard(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Lens controls
          Expanded(
            child: Column(
              children: [
                _buildFocusCard(),
                const SizedBox(height: 8),
                const IrisControl(),
                const ZoomControl(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right column - Video settings
          Expanded(
            child: Column(
              children: [
                const IsoSelector(),
                const ShutterControl(),
                const WhiteBalanceControl(),
                const SizedBox(height: 8),
                _buildTransportCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FocusSlider(),
            const SizedBox(height: 16),
            const AutofocusButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TimecodeDisplay(),
            const SizedBox(height: 16),
            const RecordButton(),
          ],
        ),
      ),
    );
  }
}
