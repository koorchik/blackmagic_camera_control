import '../models/media_state.dart';
import 'base_controller.dart';

/// Controller for media-related operations.
class MediaController extends BaseController {
  MediaController(super.context);

  /// Fetch fresh media state
  Future<void> refresh() async {
    try {
      final media = await getService()?.fetchMediaState();
      if (media != null) {
        final state = getState();
        updateState(state.copyWith(media: media));
      }
    } catch (e) {
      setError('Failed to fetch media state: $e');
    }
  }

  /// Format a media device
  Future<void> formatDevice(String deviceName, FilesystemType filesystem) async {
    final state = getState();
    updateState(state.copyWith(
      media: state.media.copyWith(
        formatInProgress: true,
        formatDeviceName: deviceName,
      ),
    ));

    try {
      await getService()?.formatDevice(deviceName, filesystem);
      // Refresh media state after format
      await refresh();
    } catch (e) {
      setError('Failed to format device: $e');
    } finally {
      final currentState = getState();
      updateState(currentState.copyWith(
        media: currentState.media.copyWith(
          formatInProgress: false,
          clearFormatDeviceName: true,
        ),
      ));
    }
  }
}
