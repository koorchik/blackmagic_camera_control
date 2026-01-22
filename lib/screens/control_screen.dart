import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_state_provider.dart';
import '../widgets/focus/focus_slider.dart';
import '../widgets/focus/focus_point_selector.dart';
import '../widgets/exposure/iso_selector.dart';
import '../widgets/exposure/shutter_control.dart';
import '../widgets/exposure/white_balance_control.dart';
import '../widgets/lens/iris_control.dart';
import '../widgets/lens/zoom_control.dart';
import '../widgets/transport/record_button.dart';
import '../widgets/transport/timecode_display.dart';
import '../widgets/slate/slate_card.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return _buildWideLayout();
        }
        return _buildNarrowLayout();
      },
    );
  }

  static Widget _buildNarrowLayout() {
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
          const SlateCard(),
          const SizedBox(height: 16),
          _buildTransportCard(),
        ],
      ),
    );
  }

  static Widget _buildWideLayout() {
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
                const SizedBox(height: 8),
                const SlateCard(),
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

  static Widget _buildFocusCard() {
    return const _FocusCard();
  }

  static Widget _buildTransportCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TimecodeDisplay(),
            SizedBox(height: 16),
            RecordButton(),
          ],
        ),
      ),
    );
  }
}

/// Focus card with slider and focus point selector.
class _FocusCard extends StatefulWidget {
  const _FocusCard();

  @override
  State<_FocusCard> createState() => _FocusCardState();
}

class _FocusCardState extends State<_FocusCard> {
  bool _isLoading = false;

  Future<void> _triggerAutofocus(double x, double y) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await context.read<CameraStateProvider>().triggerAutofocus(x: x, y: y);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FocusSlider(),
            const SizedBox(height: 16),
            FocusPointSelector(
              onPositionSelected: _triggerAutofocus,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
