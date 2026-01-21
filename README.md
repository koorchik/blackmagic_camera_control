# Blackmagic Camera Control

A sleek, cross-platform Flutter application for remotely controlling Blackmagic cameras via their REST API. Built with a focus on responsive, lag-free controls and a modern Material 3 dark interface.

## Features

- **Focus Control** - Precise manual focus slider with autofocus trigger
- **Exposure Controls** - ISO, shutter speed with auto exposure toggle
- **Lens Controls** - Iris (aperture) and zoom adjustment
- **White Balance** - Color temperature control in Kelvin
- **Transport Controls** - Start/stop recording with live timecode display
- **Real-time Updates** - WebSocket connection for instant camera state sync
- **mDNS Support** - Connect using `.local` hostnames (e.g., `micro-studio-camera-4k-g2.local`)
- **Connection Memory** - Remembers your last used camera IP

## Supported Platforms

| Platform | Status |
|----------|--------|
| Linux    | Supported |
| macOS    | Supported |
| Windows  | Supported |
| Android  | Supported |
| iOS      | Supported |

## Supported Cameras

Any Blackmagic camera with REST API support, including:

- Blackmagic Studio Camera 4K G2
- Blackmagic Studio Camera 4K Pro G2
- Blackmagic Studio Camera 4K Plus G2
- Blackmagic Studio Camera 6K Pro
- Blackmagic Cinema Camera 6K
- Blackmagic URSA Mini Pro 12K
- Other Blackmagic cameras with firmware supporting the REST API

> **Note:** Your camera must have the REST API enabled. Check your camera's network settings.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.7 or later)
- A Blackmagic camera connected to the same network as your device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/blackmagic_camera_control.git
   cd blackmagic_camera_control
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Auto-detect device
   flutter run

   # Or specify a platform
   flutter run -d linux
   flutter run -d macos
   flutter run -d windows
   flutter run -d chrome
   ```

## Usage

### Connecting to Your Camera

1. Launch the app
2. Enter your camera's IP address (e.g., `10.0.0.3`) or mDNS hostname (e.g., `micro-studio-camera-4k-g2.local`)
3. Tap **Connect**

### Controls Overview

| Control | Description |
|---------|-------------|
| **Focus Slider** | Drag to adjust focus (Near to Far) |
| **Autofocus** | Tap to trigger one-shot autofocus |
| **Iris** | Adjust aperture (Open to Close) |
| **Zoom** | Control lens zoom position |
| **ISO** | Select ISO sensitivity value |
| **Shutter** | Choose shutter speed (1/24 to 1/2000) |
| **AUTO** | Toggle automatic shutter exposure |
| **White Balance** | Adjust color temperature in Kelvin |
| **Record** | Start/stop recording |

### Tips

- All controls use **optimistic updates** - the UI responds instantly while commands are sent in the background
- The app automatically reconnects via WebSocket for real-time state updates
- Connection settings are saved automatically

## Building for Release

```bash
# Android APK
flutter build apk

# Android App Bundle (for Play Store)
flutter build appbundle

# iOS (requires macOS)
flutter build ios

# macOS
flutter build macos

# Linux
flutter build linux

# Windows
flutter build windows

# Web
flutter build web
```

## Project Structure

```
lib/
├── main.dart                 # App entry point with Provider setup
├── app.dart                  # MaterialApp configuration
├── models/                   # Data models
│   ├── camera_state.dart
│   ├── lens_state.dart
│   ├── video_state.dart
│   └── transport_state.dart
├── services/                 # API & networking
│   ├── camera_api_client.dart
│   ├── camera_service.dart
│   ├── camera_websocket.dart
│   └── mdns_resolver.dart
├── providers/                # State management
│   ├── camera_connection_provider.dart
│   └── camera_state_provider.dart
├── screens/                  # Full screens
│   ├── connection_screen.dart
│   └── control_screen.dart
├── widgets/                  # UI components
│   ├── focus/
│   ├── exposure/
│   ├── lens/
│   └── transport/
└── utils/
    └── constants.dart        # API endpoints
```

## API Reference

This app communicates with cameras using the [Blackmagic Camera REST API](https://documents.blackmagicdesign.com/DeveloperManuals/RESTAPIforBlackmagicCameras.pdf).

Key endpoints used:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/control/api/v1/lens/focus` | GET/PUT | Focus position (0.0-1.0) |
| `/control/api/v1/lens/focus/doAutoFocus` | PUT | Trigger autofocus |
| `/control/api/v1/lens/iris` | GET/PUT | Aperture position |
| `/control/api/v1/lens/zoom` | GET/PUT | Zoom position |
| `/control/api/v1/video/iso` | GET/PUT | ISO value |
| `/control/api/v1/video/shutter` | GET/PUT | Shutter speed |
| `/control/api/v1/video/whiteBalance` | GET/PUT | White balance (Kelvin) |
| `/control/api/v1/video/autoExposure` | PUT | Auto exposure mode |
| `/control/api/v1/transports/0/record` | GET/PUT | Recording state |

## Dependencies

- [provider](https://pub.dev/packages/provider) - State management
- [http](https://pub.dev/packages/http) - REST API communication
- [web_socket_channel](https://pub.dev/packages/web_socket_channel) - Real-time updates
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Persistent settings
- [multicast_dns](https://pub.dev/packages/multicast_dns) - mDNS hostname resolution

## Troubleshooting

### Cannot connect to camera

1. Ensure your camera and device are on the same network
2. Verify the camera's REST API is enabled in network settings
3. Try using the IP address instead of mDNS hostname
4. Check if a firewall is blocking the connection

### Controls not responding

1. Verify the camera is connected (green status indicator)
2. Some controls may be locked if auto exposure is enabled
3. Check if the lens supports the feature (e.g., zoom on prime lenses)

### mDNS hostname not resolving

- mDNS resolution may not work on all platforms/networks
- Use the camera's IP address as a fallback
- On Linux, ensure `avahi-daemon` is running

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Blackmagic Design for providing the REST API documentation
- The Flutter team for the excellent cross-platform framework
