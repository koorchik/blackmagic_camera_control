/// Default values used by the camera system.
/// These are used to filter out uninitialized/default values from WebSocket updates.
class CameraDefaults {
  CameraDefaults._();

  // Lens defaults
  static const double focus = 0.5;
  static const double iris = 0.0;
  static const double zoom = 0.0;

  // Video defaults
  static const int iso = 800;
  static const int shutterSpeed = 50;
  static const int whiteBalance = 5600;

  // Slate defaults
  static const int take = 1;
  static const String scene = '';
  static const bool goodTake = false;
}
