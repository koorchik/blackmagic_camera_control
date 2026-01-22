import '../models/slate_state.dart';
import 'base_controller.dart';

/// Controller for slate/metadata operations.
class SlateController extends BaseController {
  SlateController({
    required super.getState,
    required super.updateState,
    required super.setError,
    required super.getService,
  });

  /// Update slate scene
  void setScene(String scene) {
    final state = getState();
    updateState(state.copyWith(slate: state.slate.copyWith(scene: scene)));
    getService()?.updateSlate({'scene': scene}).catchError((e) {
      setError('Failed to update scene: $e');
    });
  }

  /// Update slate take number
  void setTake(int take) {
    final state = getState();
    updateState(state.copyWith(slate: state.slate.copyWith(take: take)));
    getService()?.updateSlate({'take': take}).catchError((e) {
      setError('Failed to update take: $e');
    });
  }

  /// Increment slate take number
  void incrementTake() {
    setTake(getState().slate.take + 1);
  }

  /// Update good take flag
  void setGoodTake(bool goodTake) {
    final state = getState();
    updateState(state.copyWith(slate: state.slate.copyWith(goodTake: goodTake)));
    getService()?.updateSlate({'goodTake': goodTake}).catchError((e) {
      setError('Failed to update good take: $e');
    });
  }

  /// Update shot type
  void setShotType(ShotType? shotType) {
    final state = getState();
    updateState(state.copyWith(
      slate: shotType == null
          ? state.slate.copyWith(clearShotType: true)
          : state.slate.copyWith(shotType: shotType),
    ));
    getService()?.updateSlate({
      'shotType': shotType?.code,
    }).catchError((e) {
      setError('Failed to update shot type: $e');
    });
  }

  /// Update scene location
  void setLocation(SceneLocation? location) {
    final state = getState();
    updateState(state.copyWith(
      slate: location == null
          ? state.slate.copyWith(clearSceneLocation: true)
          : state.slate.copyWith(sceneLocation: location),
    ));
    getService()?.updateSlate({
      'sceneLocation': location?.code,
    }).catchError((e) {
      setError('Failed to update location: $e');
    });
  }

  /// Update scene time
  void setTime(SceneTime? time) {
    final state = getState();
    updateState(state.copyWith(
      slate: time == null
          ? state.slate.copyWith(clearSceneTime: true)
          : state.slate.copyWith(sceneTime: time),
    ));
    getService()?.updateSlate({
      'sceneTime': time?.code,
    }).catchError((e) {
      setError('Failed to update time: $e');
    });
  }

  /// Reset slate to default values
  void reset() {
    final state = getState();
    updateState(state.copyWith(slate: const SlateState()));
    getService()?.updateSlate({
      'scene': '',
      'take': 1,
      'goodTake': false,
      'shotType': null,
      'sceneLocation': null,
      'sceneTime': null,
    }).catchError((e) {
      setError('Failed to reset slate: $e');
    });
  }

  /// Fetch fresh slate data
  Future<void> refresh() async {
    try {
      final slate = await getService()?.getSlate();
      if (slate != null) {
        final state = getState();
        updateState(state.copyWith(slate: slate));
      }
    } catch (e) {
      setError('Failed to fetch slate: $e');
    }
  }
}
