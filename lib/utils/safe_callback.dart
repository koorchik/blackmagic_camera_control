import 'package:flutter/widgets.dart';

/// Extension for safe callback execution with mounted checks.
extension SafeCallbackExtension on State {
  /// Execute a callback only if the widget is still mounted.
  /// Use this when reading from context in async callbacks.
  void safeCall(VoidCallback callback) {
    if (mounted) {
      callback();
    }
  }

  /// Execute an async callback only if the widget is still mounted.
  Future<void> safeCallAsync(Future<void> Function() callback) async {
    if (mounted) {
      await callback();
    }
  }
}
