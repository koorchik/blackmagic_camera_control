import 'dart:async';

/// A generic debouncer utility for rate-limiting function calls.
///
/// Delays execution of an action until a specified duration has passed
/// without any new calls. Useful for preventing API flooding during
/// rapid user interactions like slider dragging.
class Debouncer {
  Debouncer(this.duration);

  /// The delay duration before executing the debounced action.
  final Duration duration;

  Timer? _timer;

  /// Schedule an action to be executed after the debounce duration.
  ///
  /// If called again before the duration elapses, the previous
  /// scheduled action is cancelled and a new timer starts.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending debounced action.
  void cancel() => _timer?.cancel();

  /// Dispose of the debouncer, cancelling any pending action.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
