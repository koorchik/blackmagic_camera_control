import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({super.key});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await context.read<CameraStateProvider>().toggleRecording();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final isRecording = cameraState.transport.isRecording;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FilledButton.icon(
          onPressed: _isLoading ? null : _toggleRecording,
          style: FilledButton.styleFrom(
            backgroundColor: isRecording
                ? Color.lerp(
                    Colors.red,
                    Colors.red.shade900,
                    _animationController.value,
                  )
                : Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isRecording ? Icons.stop : Icons.fiber_manual_record,
                  color: Colors.white,
                ),
          label: Text(
            isRecording ? 'STOP' : 'REC',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
