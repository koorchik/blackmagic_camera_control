import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for video-related operations (ISO, shutter, white balance).
class VideoController {
  VideoController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Set ISO value (optimistic update)
  void setIso(int value, {Future<void> Function()? onComplete}) {
    final state = getState();
    updateState(state.copyWith(video: state.video.copyWith(iso: value)));
    getService()?.setIso(value).then((_) {
      onComplete?.call();
    }).catchError((e) {
      setError('Failed to set ISO: $e');
    });
  }

  /// Set shutter speed (optimistic update)
  void setShutterSpeed(int value) {
    final state = getState();
    updateState(state.copyWith(video: state.video.copyWith(shutterSpeed: value)));
    getService()?.setShutterSpeed(value).catchError((e) {
      setError('Failed to set shutter: $e');
    });
  }

  /// Set shutter auto exposure mode (optimistic update)
  void setShutterAutoExposure(bool enabled) {
    final mode = enabled ? 'Continuous' : 'Off';
    final state = getState();
    updateState(state.copyWith(video: state.video.copyWith(shutterAuto: enabled)));
    getService()?.setAutoExposureMode(mode, type: 'Shutter').catchError((e) {
      setError('Failed to set shutter auto exposure: $e');
    });
  }

  /// Toggle shutter auto exposure on/off
  void toggleShutterAuto() {
    setShutterAutoExposure(!getState().video.shutterAuto);
  }

  /// Refresh shutter value from camera (useful when in auto mode)
  Future<void> refreshShutterIfAuto() async {
    if (!getState().video.shutterAuto) return;

    // Small delay to let camera adjust
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final shutterData = await getService()?.api.getShutter();
      if (shutterData != null) {
        final newSpeed = shutterData['shutterSpeed'] as int?;
        final state = getState();
        if (newSpeed != null && newSpeed != state.video.shutterSpeed) {
          updateState(state.copyWith(
            video: state.video.copyWith(shutterSpeed: newSpeed),
          ));
        }
      }
    } catch (e) {
      // Ignore errors during refresh
    }
  }

  /// Set white balance in Kelvin (optimistic update)
  void setWhiteBalance(int kelvin) {
    final state = getState();
    updateState(state.copyWith(video: state.video.copyWith(whiteBalance: kelvin)));
    getService()?.setWhiteBalance(kelvin).catchError((e) {
      setError('Failed to set white balance: $e');
    });
  }

  /// Set white balance tint (optimistic update)
  void setWhiteBalanceTint(int tint) {
    final state = getState();
    updateState(state.copyWith(video: state.video.copyWith(whiteBalanceTint: tint)));
    getService()?.setWhiteBalanceTint(tint).catchError((e) {
      setError('Failed to set tint: $e');
    });
  }

  /// Trigger auto white balance and refresh white balance value
  Future<void> triggerAutoWhiteBalance() async {
    try {
      await getService()?.triggerAutoWhiteBalance();
      // Wait a moment for camera to calculate, then refresh WB value
      await Future.delayed(const Duration(milliseconds: 300));
      final newWb = await getService()?.api.getWhiteBalance();
      if (newWb != null) {
        final state = getState();
        updateState(state.copyWith(
          video: state.video.copyWith(whiteBalance: newWb),
        ));
      }
    } catch (e) {
      setError('Failed to trigger auto white balance: $e');
    }
  }
}
