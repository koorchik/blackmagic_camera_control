import '../models/color_correction_state.dart';
import 'base_controller.dart';

/// Controller for color correction operations.
class ColorController extends BaseController {
  ColorController(super.context);

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

  // ========== LIFT (SHADOWS) ==========

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

  // ========== GAMMA (MIDTONES) ==========

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

  // ========== GAIN (HIGHLIGHTS) ==========

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

  // ========== OFFSET (BLACKS) ==========

  /// Set color offset (blacks) - debounced
  void setOffsetDebounced(ColorWheelValues values) {
    getService()?.setColorOffsetDebounced(values);
  }

  /// Set color offset (blacks) - final value
  void setOffsetFinal(ColorWheelValues values) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(offset: values),
    ));
    getService()?.setColorOffset(values);
  }

  // ========== SATURATION ==========

  /// Set saturation (uses combined /colorCorrection/color endpoint)
  /// Always sends both hue and saturation as API expects both values together
  void setSaturation(double value) {
    final state = getState();
    final currentHue = state.colorCorrection.hue;
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(saturation: value),
    ));
    getService()?.setColorProperties(saturation: value, hue: currentHue).catchError((e) {
      setError('Failed to set saturation: $e');
    });
  }

  /// Set saturation - debounced (API only, no state update for smooth dragging)
  void setSaturationDebounced(double value) {
    final currentHue = getState().colorCorrection.hue;
    getService()?.setColorPropertiesDebounced(saturation: value, hue: currentHue);
  }

  // ========== HUE ==========

  /// Set hue (uses combined /colorCorrection/color endpoint)
  /// Always sends both hue and saturation as API expects both values together
  void setHue(double value) {
    final state = getState();
    final currentSaturation = state.colorCorrection.saturation;
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(hue: value),
    ));
    getService()?.setColorProperties(hue: value, saturation: currentSaturation).catchError((e) {
      setError('Failed to set hue: $e');
    });
  }

  /// Set hue - debounced (API only, no state update for smooth dragging)
  void setHueDebounced(double value) {
    final currentSaturation = getState().colorCorrection.saturation;
    getService()?.setColorPropertiesDebounced(hue: value, saturation: currentSaturation);
  }

  // ========== CONTRAST WITH PIVOT ==========

  /// Set contrast (uses /colorCorrection/contrast with adjust field)
  void setContrast(double value) {
    final state = getState();
    final pivot = state.colorCorrection.contrastPivot;
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(contrast: value),
    ));
    getService()?.setColorContrastWithPivot(value, pivot).catchError((e) {
      setError('Failed to set contrast: $e');
    });
  }

  /// Set contrast - debounced (API only, no state update for smooth dragging)
  void setContrastDebounced(double value) {
    final pivot = getState().colorCorrection.contrastPivot;
    getService()?.setColorContrastWithPivotDebounced(value, pivot);
  }

  /// Set contrast pivot point
  void setContrastPivot(double value) {
    final state = getState();
    final contrast = state.colorCorrection.contrast;
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(contrastPivot: value),
    ));
    getService()?.setColorContrastWithPivot(contrast, value).catchError((e) {
      setError('Failed to set contrast pivot: $e');
    });
  }

  /// Set contrast pivot - debounced (API only, no state update for smooth dragging)
  void setContrastPivotDebounced(double value) {
    final contrast = getState().colorCorrection.contrast;
    getService()?.setColorContrastWithPivotDebounced(contrast, value);
  }

  // ========== LUMA CONTRIBUTION ==========

  /// Set luma contribution
  void setLumaContribution(double value) {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.copyWith(lumaContribution: value),
    ));
    getService()?.setColorLumaContribution(value).catchError((e) {
      setError('Failed to set luma contribution: $e');
    });
  }

  /// Set luma contribution - debounced (API only, no state update for smooth dragging)
  void setLumaContributionDebounced(double value) {
    getService()?.setColorLumaContributionDebounced(value);
  }

  // ========== RESET ==========

  /// Reset all color correction to default
  void reset() {
    final state = getState();
    updateState(state.copyWith(
      colorCorrection: state.colorCorrection.reset(),
    ));
    // Reset each component with correct defaults
    final service = getService();
    if (service == null) return;

    // Lift, Gamma, Offset use 0.0 (additive)
    service.setColorLift(ColorWheelValues.liftGammaDefault);
    service.setColorGamma(ColorWheelValues.liftGammaDefault);
    service.setColorOffset(ColorWheelValues.liftGammaDefault);
    // Gain uses 1.0 (multiplicative)
    service.setColorGain(ColorWheelValues.gainDefault);
    // Reset saturation and hue via combined endpoint
    service.setColorProperties(saturation: 1.0, hue: 0.0);
    // Reset contrast with pivot
    service.setColorContrastWithPivot(1.0, 0.5);
    // Reset luma contribution
    service.setColorLumaContribution(1.0);
  }
}
