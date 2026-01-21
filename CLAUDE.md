# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter application for controlling Blackmagic cameras via their REST API and WebSocket interface. Supports lens control (focus, iris, zoom), video settings (ISO, shutter, white balance), and transport control (record, timecode).

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
- `CameraConnectionProvider` - Manages connection state and camera IP persistence
- `CameraStateProvider` - Holds camera state, subscribes to WebSocket updates, calls API

**Service Layer** (`lib/services/`):
- `CameraApiClient` - REST API client for GET/PUT operations to camera endpoints
- `CameraWebSocket` - WebSocket client for real-time state updates from camera
- `CameraService` - Facade combining both clients, adds debouncing for slider controls (150ms)

**Data Flow**:
1. User connects via `ConnectionScreen` → `CameraConnectionProvider.connect(ip)`
2. On success, `ControlScreen` initializes `CameraStateProvider` with `CameraService`
3. Provider fetches initial state via REST, then subscribes to WebSocket streams
4. UI widgets read from provider, call provider methods which update local state optimistically then call debounced API

**Models** (`lib/models/`): Immutable state classes with `copyWith` - `LensState`, `VideoState`, `TransportState`, aggregated in `CameraState`

**API Endpoints**: Defined in `lib/utils/constants.dart` - all under `/control/api/v1/`

## Key Patterns

- Slider values (focus, iris, zoom) use debounced API calls to avoid flooding
- WebSocket updates partial state; provider merges with existing state
- 404 responses indicate unsupported features (handled gracefully)
- Last camera IP persisted via SharedPreferences
