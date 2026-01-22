import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Base class for all camera controllers.
///
/// Provides shared constructor pattern with callbacks for state access/mutation.
abstract class BaseController {
  BaseController({
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
