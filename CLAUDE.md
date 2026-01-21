# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter application for Blackmagic camera control. Currently in early development stage with the default Flutter counter template.

## Common Commands

```bash
# Run the app
flutter run

# Run with hot reload on specific device
flutter run -d <device_id>

# Analyze code for issues
flutter analyze

# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Get dependencies
flutter pub get

# Build for release
flutter build apk        # Android
flutter build ios        # iOS
flutter build macos      # macOS
flutter build linux      # Linux
flutter build windows    # Windows
flutter build web        # Web
```

## Project Structure

- `lib/` - Main Dart source code, entry point is `lib/main.dart`
- `test/` - Widget and unit tests
- `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `web/` - Platform-specific code

## Dependencies

- Dart SDK: ^3.10.7
- Uses `flutter_lints` for static analysis (configured in `analysis_options.yaml`)
