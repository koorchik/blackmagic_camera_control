# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter application for controlling Blackmagic cameras via their REST API and WebSocket interface. Supports lens control, video settings, transport, audio, media, monitoring overlays, and color correction.

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

## Architecture

**State Management**: Provider pattern with two main providers:
- `CameraConnectionProvider` - Manages connection state, camera IP persistence, and mDNS discovery
- `CameraStateProvider` - Holds camera state, manages 8 domain controllers, subscribes to WebSocket updates

**Controllers** (`lib/controllers/`): Domain-specific logic extracted from provider:
- `LensController` - Focus, iris, zoom, autofocus
- `VideoController` - ISO, shutter, white balance, auto exposure
- `TransportController` - Record, stop, timecode
- `SlateController` - Scene, take, shot type, good take metadata
- `AudioController` - Channel levels, inputs, phantom power, low-cut filter
- `MediaController` - Storage devices, format card
- `MonitoringController` - Focus assist, zebra, frame guides, clean feed
- `ColorController` - Lift, gamma, gain, saturation, contrast color wheels

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

**API Endpoints**: Defined in `lib/utils/constants.dart` - all under `/control/api/v1/`

## Key Patterns

- Slider values (focus, iris, zoom) use debounced API calls (50ms) to avoid flooding
- Color correction uses longer debounce (100ms) for stability
- WebSocket updates partial state; provider merges with existing state
- 404 responses indicate unsupported features (handled gracefully)
- Last camera IP persisted via SharedPreferences
- Optimistic UI updates - state changes immediately, API calls in background
