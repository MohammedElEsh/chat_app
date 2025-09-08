# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Flutter chat application with Firebase backend integration. The app uses Firebase for authentication, Cloud Firestore for data storage, Firebase Storage for file uploads, and Firebase Messaging for push notifications. The project is set up to support cross-platform deployment (Android, iOS, Web, Windows, macOS, Linux).

## Development Commands

### Dependencies
```powershell
# Install/update dependencies
flutter pub get

# Upgrade dependencies to latest versions
flutter pub upgrade

# Generate dependency lock file
flutter pub deps

# Check for outdated packages
flutter pub outdated
```

### Code Generation
```powershell
# Generate injectable dependency injection code
flutter packages pub run build_runner build

# Watch for changes and regenerate automatically
flutter packages pub run build_runner watch

# Clean generated files and regenerate
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Running the App
```powershell
# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release

# Hot restart
flutter run --hot

# List available devices
flutter devices
```

### Testing
```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Code Analysis and Linting
```powershell
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Format specific files
flutter format lib/main.dart

# Check formatting without making changes
flutter format --dry-run lib/
```

### Building
```powershell
# Build APK for Android
flutter build apk

# Build app bundle for Google Play
flutter build appbundle

# Build for iOS (requires macOS and Xcode)
flutter build ios

# Build for web
flutter build web

# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux
```

### Firebase Commands
```powershell
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init

# Deploy to Firebase Hosting (web builds)
firebase deploy --only hosting

# Deploy Firebase Functions
firebase deploy --only functions

# Set Firebase project
firebase use <project-id>
```

## Architecture Overview

### Current Structure
The application currently uses a simple single-file architecture in `lib/main.dart` with all components defined in one place:

- **MyApp**: Root application widget with MaterialApp configuration
- **AuthGate**: Handles authentication state and routes to appropriate screens
- **LoginPage**: Authentication screen with email/password login and registration
- **HomePage**: Post-authentication landing screen

### Dependencies Overview

**Core Flutter & Firebase:**
- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: NoSQL database
- `firebase_storage`: File storage
- `firebase_messaging`: Push notifications

**State Management & Architecture:**
- `flutter_bloc`: BLoC pattern for state management
- `equatable`: Value equality for Dart classes
- `get_it`: Service locator for dependency injection
- `injectable`: Code generation for dependency injection
- `dartz`: Functional programming constructs

**UI & Media:**
- `image_picker`: Camera and gallery image selection
- `voice_message_package`: Voice message recording and playback
- `permission_handler`: Runtime permissions management

**Utilities:**
- `shared_preferences`: Local key-value storage

**Development:**
- `build_runner`: Code generation runner
- `injectable_generator`: DI code generation
- `mocktail`: Mocking for tests
- `bloc_test`: Testing utilities for BLoC
- `flutter_lints`: Linting rules

### Expected Architecture Patterns

Based on the dependencies, the app is prepared for:

1. **BLoC Pattern**: State management using `flutter_bloc` with events and states
2. **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
3. **Dependency Injection**: Using `get_it` and `injectable` for service registration
4. **Repository Pattern**: Abstraction layer for data sources using `dartz` for functional error handling
5. **Feature-based Organization**: Likely future structure organizing code by features rather than layers

### Firebase Configuration

- **Project ID**: chatapp-1ced9
- **Platforms Configured**: Android, iOS, Web, Windows, macOS
- **Services**: Authentication, Firestore, Storage, Messaging
- **Configuration**: Auto-generated in `lib/firebase_options.dart`

### Testing Strategy

- **Widget Testing**: Basic widget tests in `test/widget_test.dart`
- **BLoC Testing**: Ready for bloc testing with `bloc_test` package
- **Mocking**: Uses `mocktail` for creating test doubles
- **Coverage**: Supports test coverage reporting

## Development Notes

- The app uses Flutter SDK ^3.9.0
- Material Design is the current UI framework
- Firebase project is already configured for all major platforms
- Code generation is required when adding new injectable dependencies
- The current implementation is a starting template - the architecture is set up for expansion into a more complex, scalable chat application

## Platform-Specific Setup

### Android
- Configuration in `android/` directory
- Uses Gradle Kotlin DSL (build.gradle.kts)
- Google Services JSON configured via Firebase CLI

### iOS
- Configuration in `ios/` directory
- Requires Xcode for building
- Firebase plist configured automatically

### Web
- Configuration in `web/` directory
- Firebase web configuration included
- Can be deployed to Firebase Hosting

### Desktop (Windows/macOS/Linux)
- CMake-based build system
- Platform-specific configurations in respective directories
