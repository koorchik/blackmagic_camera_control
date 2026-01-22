import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Shared context object for all controllers.
///
/// Encapsulates the callbacks that controllers need for state access/mutation.
/// This reduces boilerplate when initializing controllers in the provider.
class ControllerContext {
  const ControllerContext({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  /// Callback to get the current camera state.
  final CameraState Function() getState;

  /// Callback to update the camera state.
  final void Function(CameraState state) updateState;

  /// Callback to set an error message.
  final void Function(String error) setError;

  /// Callback to get the camera service (may be null if not connected).
  final CameraService? Function() getService;
}
