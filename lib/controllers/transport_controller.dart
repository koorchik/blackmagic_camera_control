import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for transport-related operations (recording, timecode).
class TransportController {
  TransportController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Start recording
  Future<void> startRecording() async {
    final service = getService();
    if (service == null) return;

    try {
      await service.startRecording();

      // Wait a moment for the camera to process the command
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify the actual recording state
      final actualState = await service.api.getRecordingState();
      final state = getState();
      updateState(state.copyWith(
        transport: state.transport.copyWith(isRecording: actualState),
      ));

      if (!actualState) {
        setError('Failed to start recording. Check media is inserted and has space.');
      }
    } catch (e) {
      setError('Failed to start recording: $e');
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    final service = getService();
    if (service == null) return;

    try {
      await service.stopRecording();

      // Wait a moment for the camera to process the command
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify the actual recording state
      final actualState = await service.api.getRecordingState();
      final state = getState();
      updateState(state.copyWith(
        transport: state.transport.copyWith(isRecording: actualState),
      ));

      if (actualState) {
        setError('Failed to stop recording.');
      }
    } catch (e) {
      setError('Failed to stop recording: $e');
    }
  }

  /// Toggle recording state
  Future<void> toggleRecording() async {
    if (getState().transport.isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }
}
