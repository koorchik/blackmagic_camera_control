import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for color correction operations.
class ColorController {
  ColorController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Fetch fresh color correction state
  Future<void> refresh() async {
    try {
      final colorCorrection = await getService()?.fetchColorCorrectionState();
      if (colorCorrection != null) {
        final state = getState();
        updateState(state.copyWith(colorCorrection: colorCorrection));
      }
    } catch (e) {
      setError('Failed to fetch color correction state: $e');
    }
  }

  /// Set color lift (shadows) - debounced
  void setLiftDebounced(ColorWheelValues values) {
    getService()?.setColorLiftDebounced(values);
  }

  /// Set color lift (shadows) - final value
  void setLiftFinal(ColorWheelValues values) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(lift: values),
    ));
    getService()?.setColorLift(values);
  }

  /// Set color gamma (midtones) - debounced
  void setGammaDebounced(ColorWheelValues values) {
    getService()?.setColorGammaDebounced(values);
  }

  /// Set color gamma (midtones) - final value
  void setGammaFinal(ColorWheelValues values) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(gamma: values),
    ));
    getService()?.setColorGamma(values);
  }

  /// Set color gain (highlights) - debounced
  void setGainDebounced(ColorWheelValues values) {
    getService()?.setColorGainDebounced(values);
  }

  /// Set color gain (highlights) - final value
  void setGainFinal(ColorWheelValues values) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(gain: values),
    ));
    getService()?.setColorGain(values);
  }

  /// Set saturation
  void setSaturation(double value) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(saturation: value),
    ));
    getService()?.setColorSaturation(value).catchError((e) {
      setError('Failed to set saturation: $e');
    });
  }

  /// Set contrast
  void setContrast(double value) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(contrast: value),
    ));
    getService()?.setColorContrast(value).catchError((e) {
      setError('Failed to set contrast: $e');
    });
  }

  /// Set hue
  void setHue(double value) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(hue: value),
    ));
    getService()?.setColorHue(value).catchError((e) {
      setError('Failed to set hue: $e');
    });
  }

  /// Reset all color correction to default
  void reset() {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.reset(),
    ));
    // Reset each component with correct defaults
    // Lift and Gamma use 0.0 (additive), Gain uses 1.0 (multiplicative)
    getService()?.setColorLift(ColorWheelValues.liftGammaDefault);
    getService()?.setColorGamma(ColorWheelValues.liftGammaDefault);
    getService()?.setColorGain(ColorWheelValues.gainDefault);
  }
}
