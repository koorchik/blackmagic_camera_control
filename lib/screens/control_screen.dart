import 'package:flutter/material.dart';
import '../widgets/focus/focus_slider.dart';
import '../widgets/focus/autofocus_button.dart';
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
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FocusSlider(),
            SizedBox(height: 16),
            AutofocusButton(),
          ],
        ),
      ),
    );
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
