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
- `CameraStateProvider` - Holds camera state, manages 8 domain controllers, subscribes to WebSocket updates

**Controllers** (`lib/controllers/`): Domain-specific logic extracted from provider. Each controller receives callbacks for state access/mutation via constructor injection:
```dart
LensController({
  required this.getState,      // CameraState Function()
  required this.updateState,   // void Function(CameraState)
  required this.setError,      // void Function(String)
  required this.getService,    // CameraService? Function()
})
```
Controllers: `LensController`, `VideoController`, `TransportController`, `SlateController`, `AudioController`, `MediaController`, `MonitoringController`, `ColorController`

**Service Layer** (`lib/services/`):
- `CameraApiClient` - REST API client for GET/PUT operations to camera endpoints
- `CameraWebSocket` - WebSocket client for real-time state updates from camera
- `CameraService` - Facade combining both clients, adds debouncing (50ms sliders, 100ms color)
- `CameraDiscoveryService` - mDNS-based camera autodiscovery with validation

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

- **Slider debouncing**: Controllers have paired methods - `setFocusDebounced()` for smooth dragging (API only, 50ms debounce), `setFocusFinal()` for drag end (updates state + immediate API call)
- **Color correction debouncing**: 100ms for stability
- **WebSocket state merging**: Partial updates merged with existing state in provider
- **404 handling**: Indicates unsupported camera features, handled gracefully
- **Optimistic UI**: State changes immediately, API calls in background
- **Persistence**: Last camera IP stored via SharedPreferences (`PrefsKeys.lastCameraIp`)
