# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter application for controlling Blackmagic cameras via their REST API and WebSocket interface. Supports lens control, video settings, transport, audio, media, monitoring overlays, and color correction.

**Requirements**: Flutter SDK 3.10.7+, Dart SDK ^3.10.7

## Common Commands

```bash
flutter run                          # Run the app
flutter run -d linux                 # Run on specific platform
flutter analyze                      # Check for issues
flutter test                         # Run all tests
flutter test test/widget_test.dart   # Run specific test
flutter pub get                      # Install dependencies
flutter build linux --debug          # Build for platform
```

Testing uses `mocktail` for mocking.

## Architecture

**State Management**: Provider pattern with two main providers:

- `CameraConnectionProvider` - Manages connection state, camera IP persistence, and mDNS discovery
- `CameraStateProvider` - Holds camera state, manages 9 domain controllers, subscribes to WebSocket updates

**Controllers** (`lib/controllers/`): Domain-specific logic extracted from provider. All controllers extend `BaseController` and receive a shared `ControllerContext` for state access/mutation:

```dart
// ControllerContext bundles all callbacks needed by controllers
final ctx = ControllerContext(
  getState: () => _state,
  updateState: _updateState,
  setError: _setError,
  getService: () => _cameraService,
);

// Controllers use simplified constructor
_lensController = LensController(ctx);
_videoController = VideoController(ctx);
```

Controllers: `LensController`, `VideoController`, `TransportController`, `SlateController`, `AudioController`, `MediaController`, `MonitoringController`, `ColorController`, `PresetController`

**Service Layer** (`lib/services/`):

- `CameraApiClient` - REST API client for GET/PUT operations to camera endpoints
- `CameraWebSocket` - WebSocket client for real-time state updates from camera
- `CameraService` - Facade combining both clients, exposes `api` accessor for direct API access, adds debouncing via `Debouncer` utility (50ms sliders, 100ms color)
- `CameraDiscoveryService` - mDNS-based camera autodiscovery with validation

**Utilities** (`lib/utils/`):

- `Debouncer` - Generic debouncer utility for rate-limiting function calls (used by CameraService)

**Data Flow**:

1. User connects via `ConnectionScreen` → `CameraConnectionProvider.connect(ip)`
2. On success, `MainScreen` initializes `CameraStateProvider` with `CameraService`
3. Provider fetches initial state via REST, then subscribes to WebSocket streams
4. UI widgets read from provider, call controller methods which update local state optimistically then call debounced API

**Models** (`lib/models/`): Immutable state classes with `copyWith`:

- `CameraState` - Root aggregate containing all substates
- `LensState`, `VideoState`, `TransportState`, `SlateState`
- `AudioState`, `MediaState`, `MonitoringState`, `ColorCorrectionState`
- `CameraCapabilities` - Feature discovery (supported ISOs, shutter speeds, etc.)

**Screen Navigation**: Tab-based with 5 main screens after connection:

- `ControlScreen` - Primary lens, exposure, transport controls
- `AudioScreen` - Audio channel configuration and levels
- `MediaScreen` - Storage info and format operations
- `MonitoringScreen` - Display overlays configuration
- `ColorScreen` - Color correction wheels

**API Endpoints**: Defined in `lib/utils/constants.dart` (`ApiEndpoints` class) - all REST endpoints under `/control/api/v1/`, WebSocket at `ws://{host}/control/api/v1/event/websocket`

**Constants** (`lib/utils/constants.dart`): Also contains `PrefsKeys` (SharedPreferences keys), `Durations` (debounce timings), and `DiscoveryConstants` (mDNS settings)

## Key Patterns

- **Slider pattern** (CRITICAL for web performance): ALL sliders use local widget state during drag:
  - Widgets: `_draggingValue` local state, updates via `setState()` during drag
  - `onChanged` → optional debounced API call only (no provider state update)
  - `onChangeEnd` → provider state update + final API call
  - Controllers: paired methods `setXxxDebounced()` + `setXxxFinal()`
  - Both `ContinuousSliderControl` and `DiscreteSliderControl` follow this pattern
- **Color correction debouncing**: 100ms for stability
- **WebSocket state merging**: Partial updates merged with existing state in provider
- **404 handling**: Indicates unsupported camera features, handled gracefully
- **Optimistic UI**: State changes immediately, API calls in background. Use `BaseController.optimisticUpdate()` helper for standard pattern with automatic rollback on error:
  ```dart
  optimisticUpdate(
    updater: (state) => state.copyWith(video: state.video.copyWith(iso: value)),
    apiCall: () => getService()!.setIso(value),
    errorMessage: 'Failed to set ISO',
  );
  ```
- **Direct API access**: Controllers can use `getService()?.api.method()` for simple read operations (e.g., `service.api.getShutter()`)
- **Persistence**: Last camera IP stored via SharedPreferences (`PrefsKeys.lastCameraIp`)

## Reusable UI Components

Use widgets from `lib/widgets/common/` to maintain consistency:

| Component | Use Case |
|-----------|----------|
| `ControlCard` | Card wrapper with standard padding |
| `ToggleControlRow` | Icon + title + description + Switch |
| `DebouncedSlider` | Core slider with local drag state (use for raw sliders) |
| `DiscreteSliderControl<T>` | Slider with discrete values (ISO, shutter) |
| `ContinuousSliderControl` | Slider with debounce-aware state (focus, iris, zoom) |
| `CollapsibleControlCard` | Card with toggle that shows/hides content |
| `DropdownControlRow<T>` | Icon + title + dropdown selector |
| `ChipSelectionGroup<T>` | Wrap of ChoiceChips |
| `ResponsiveLayout` | LayoutBuilder wrapper with breakpoint handling |

### UI Guidelines

1. **Always prefer common components** over duplicating patterns
2. **Use `Spacing` constants** instead of `SizedBox(height: 16)` - use `Spacing.verticalLg`
3. **Use `Breakpoints.medium`** instead of hardcoded `800` for responsive layouts
4. **ChoiceChip**: Use `ChipSelectionGroup` - it handles `showCheckmark: false` automatically
5. **All sliders**: Must use `onChangeEnd` for provider state updates. Use `onChanged` only for debounced API calls. Never update provider state in `onChanged` - causes lag on web.

### Constants (`lib/utils/constants.dart`)

- `Spacing.xs/sm/md/lg/xl/xxl` - Spacing values (4/8/12/16/24/32)
- `Spacing.cardPadding` - Standard card padding `EdgeInsets.all(16)`
- `Spacing.verticalSm/Md/Lg` - Const SizedBox widgets for vertical spacing
- `Spacing.horizontalSm/Md/Lg` - Const SizedBox widgets for horizontal spacing
- `Breakpoints.compact/medium/expanded` - Layout breakpoints (600/800/1000)
- `Styles.borderRadiusSmall` - Standard small border radius (8.0)
- `Styles.sliderLabelFontSize` - Slider sparse label font size (10.0)
- `Styles.sliderValueFontSize` - Slider value display font size (14.0)
- `Durations.sliderDebounce` - 50ms debounce for slider controls
- `Durations.colorCorrectionDebounce` - 100ms debounce for color correction

### Adding New Controllers

1. Create controller extending `BaseController` with `YourController(super.context)`
2. Add controller field and getter to `CameraStateProvider`
3. Initialize in `_initControllers()` using the shared `ControllerContext`

### Using Debouncer

```dart
final _debouncer = Debouncer(Duration(milliseconds: 100));
_debouncer.call(() => performAction());
_debouncer.dispose(); // Clean up when done
```

### Slider Pattern (Web Performance)

All sliders follow the same pattern to avoid UI lag. Use `DebouncedSlider` as the building block:

**Widget layer** - Use `DebouncedSlider` instead of raw `Slider`:
```dart
// Simple - DebouncedSlider handles local state internally
DebouncedSlider(
  value: providerValue,
  min: 0,
  max: 100,
  onChanged: (v) => provider.setFooDebounced(v),  // API only
  onChangeEnd: (v) => provider.setFooFinal(v),     // State + API
)
```

**Controller layer** - Paired methods:
```dart
void setFooDebounced(double value) {
  getService()?.setFooDebounced(value);  // API only, NO state update
}

void setFooFinal(double value) {
  updateState(state.copyWith(foo: value));  // State update
  getService()?.setFoo(value);              // Immediate API
}
```

**Service layer** - Debounced calls:
```dart
void setFooDebounced(double value) {
  _sliderDebouncer.call(() => setFoo(value));
}
```

**Slider components hierarchy:**
- `DebouncedSlider` - Core building block, handles local drag state
- `ContinuousSliderControl` - Uses DebouncedSlider + title header + card (for lens controls)
- `DiscreteSliderControl<T>` - Handles discrete values + sparse labels (for ISO, shutter)

## Camera REST API Docs

Files from the folder docs/rest-api-specs

## Testing

When I develop, I have camera online on 10.0.0.3 ip address. Use it for checking that endpoints are working correctly.
