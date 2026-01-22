import '../models/camera_state.dart';
import '../services/camera_service.dart';
import 'controller_context.dart';

/// Base class for all camera controllers.
///
/// Provides shared context with callbacks for state access/mutation.
abstract class BaseController {
  BaseController(this.context);

  /// The shared context containing callbacks for state management.
  final ControllerContext context;

  /// Callback to get the current camera state.
  CameraState Function() get getState => context.getState;

  /// Callback to update the camera state.
  void Function(CameraState state) get updateState => context.updateState;

  /// Callback to set an error message.
  void Function(String error) get setError => context.setError;

  /// Callback to get the camera service (may be null if not connected).
  CameraService? Function() get getService => context.getService;

  /// Performs an optimistic update: applies state change immediately,
  /// then makes API call. On error, reverts to previous state and shows error.
  ///
  /// Example:
  /// ```dart
  /// optimisticUpdate(
  ///   updater: (state) => state.copyWith(video: state.video.copyWith(iso: value)),
  ///   apiCall: () => getService()!.setIso(value),
  ///   errorMessage: 'Failed to set ISO',
  /// );
  /// ```
  void optimisticUpdate({
    required CameraState Function(CameraState) updater,
    required Future<void> Function() apiCall,
    String? errorMessage,
  }) {
    final previousState = getState();
    updateState(updater(previousState));

    apiCall().catchError((e) {
      updateState(previousState);
      if (errorMessage != null) {
        setError('$errorMessage: $e');
      }
    });
  }
}
