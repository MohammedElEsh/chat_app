# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Flutter chat application built with Firebase backend integration, featuring real-time messaging, voice/video calling via ZegoCloud, and comprehensive user authentication. The app follows Clean Architecture principles with feature-based organization and uses BLoC pattern for state management.

## Architecture

### Clean Architecture Implementation
The codebase follows Clean Architecture with three layers:

- **Domain Layer** (`lib/features/*/domain/`): Contains business logic, entities, repositories interfaces, and use cases
- **Data Layer** (`lib/features/*/data/`): Implements repositories, handles external data sources (Firebase), and contains data models
- **Presentation Layer** (`lib/features/*/presentation/`): Contains UI components, BLoC state management, pages, and widgets

### Feature Structure
Each feature follows this consistent structure:
```
features/
├── auth/          # Authentication (login, register, logout)
├── chat/          # Real-time messaging with text, images, voice messages
├── call/          # Voice/video calling via ZegoCloud
└── home/          # Chat list, user discovery, main navigation
```

### Key Architectural Patterns
- **BLoC Pattern**: All business logic uses flutter_bloc for state management
- **Repository Pattern**: Data access abstracted through repository interfaces
- **Use Case Pattern**: Each business operation is encapsulated in a use case class
- **Dependency Injection**: Manual DI setup in main.dart with clear dependency chains
- **Either Pattern**: Uses `dartz` package for functional error handling with `Either<Failure, Success>`

### Core Services
- **Firebase Integration**: Authentication, Firestore database, Cloud Storage, Cloud Messaging
- **ZegoCloud Integration**: Real-time voice/video calling functionality
- **Connectivity Service**: Network status monitoring for call quality
- **Call Invitation Service**: Hybrid system using both ZegoCloud and Firestore for reliability

### State Management Flow
1. UI dispatches events to BLoC
2. BLoC calls appropriate use case
3. Use case interacts with repository
4. Repository communicates with data sources (Firebase)
5. Results flow back through the chain with proper error handling

## Development Commands

### Essential Flutter Commands
```bash
# Get dependencies
flutter pub get

# Run the app in development mode
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d android         # Android

# Build for production
flutter build apk             # Android APK
flutter build appbundle       # Android App Bundle
flutter build windows         # Windows executable
flutter build web             # Web build
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Run tests with verbose output
flutter test --verbose
```

### Code Analysis and Formatting
```bash
# Analyze code for issues
flutter analyze

# Format all Dart files
dart format .

# Format specific file
dart format lib/main.dart

# Check for outdated packages
flutter pub outdated
```

### Firebase Commands
```bash
# Configure Firebase for different platforms
flutterfire configure

# Deploy Firestore rules
firebase deploy --only firestore:rules

# View Firebase project info
firebase projects:list
```

### Asset Management
```bash
# Generate app icons (uses flutter_launcher_icons)
dart run flutter_launcher_icons
```

### Development Workflow Commands
```bash
# Hot reload (during development)
r

# Hot restart (during development)
R

# Clean build artifacts
flutter clean && flutter pub get

# Run in release mode for performance testing
flutter run --release
```

## Firebase Configuration

### Collections Structure
- **users**: User profiles with authentication data
- **messages**: Global messages collection with real-time updates
- **chatRooms**: Future chat room functionality (currently unused)
- **call_invitations**: Call invitation management for video/voice calls

### Security Rules
The Firestore rules ensure:
- Users can only read/write their own user documents
- Authenticated users can read other users' public information
- Users can only send messages with their own user ID
- Messages cannot be deleted (append-only for data integrity)
- Call invitations follow proper sender/receiver permissions

### Firebase Services Used
- **Authentication**: Email/password authentication
- **Firestore**: Real-time database for messages and user data
- **Cloud Storage**: File upload for images and voice messages
- **Cloud Messaging**: Push notifications for call invitations

## Key Dependencies

### State Management & Architecture
- `flutter_bloc`: BLoC pattern implementation
- `equatable`: Value equality for entities and states
- `dartz`: Functional programming with Either for error handling

### Firebase Integration
- `firebase_core`: Firebase initialization
- `firebase_auth`: User authentication
- `cloud_firestore`: Real-time database
- `firebase_storage`: File storage
- `firebase_messaging`: Push notifications

### Communication Features
- `zego_uikit_prebuilt_call`: Video/voice calling UI components
- `zego_uikit_signaling_plugin`: Real-time signaling for calls
- `voice_message_package`: Voice message recording and playback

### UI & Navigation
- `go_router`: Declarative routing
- `provider`: Additional state management for simple cases
- `image_picker`: Camera and gallery access for images

### Utilities
- `permission_handler`: Runtime permissions management
- `shared_preferences`: Local data persistence
- `intl`: Internationalization and date formatting

## Development Guidelines

### State Management
- Use BLoC for all business logic and complex state
- Use Provider only for simple dependency injection
- Always handle both success and failure states in BLoC events
- Use Equatable for all entities, states, and events

### Error Handling
- Use Either<Failure, Success> pattern from dartz
- Define specific failure types in `core/errors/failures.dart`
- Always propagate meaningful error messages to the UI
- Handle network connectivity issues gracefully

### Firebase Integration
- All Firebase operations should go through repository abstractions
- Use streams for real-time data (Firestore snapshots)
- Implement proper error handling for Firebase exceptions
- Follow Firestore security rules when designing data operations

### Testing Strategy
- Write unit tests for use cases and repositories
- Use mocktail for mocking dependencies
- Test BLoC states and events with bloc_test
- Widget tests should cover critical user flows

### Code Organization
- Keep feature folders self-contained
- Use barrel exports (index.dart files) sparingly
- Place shared utilities in `core/` directory
- Follow consistent naming conventions across layers

## Call Functionality Integration

### ZegoCloud Setup
The app uses ZegoCloud for real-time communication with credentials in `core/config/zego_config.dart`. The integration includes:
- Hybrid call system (ZegoCloud + Firestore backup)
- Permission handling for camera/microphone
- Call invitation timeout management
- Network connectivity checks before calls

### Call Flow
1. User initiates call from chat interface
2. System checks permissions and network connectivity
3. Call invitation sent via both ZegoCloud and Firestore
4. Recipient receives invitation through multiple channels
5. Call established with proper session tracking
6. Cleanup and session termination handling

## Platform-Specific Considerations

### Windows Development
- Uses CMake build system
- Ensure Visual Studio build tools are installed
- Firebase Windows configuration handled in `firebase_options.dart`

### Android Development
- Minimum SDK version: 21
- Uses Gradle Kotlin DSL (`.gradle.kts` files)
- Firebase configuration via `google-services.json`

### iOS Development
- Firebase configuration handled automatically
- Requires proper provisioning profiles for calls
- Camera/microphone permissions handled in Info.plist

### Web Development
- Firebase web configuration included
- Limited call functionality due to browser restrictions
- CORS considerations for Firebase operations

## Common Issues and Solutions

### Firebase Connection Issues
- Ensure `firebase_options.dart` is properly configured
- Check that Firebase project settings match the app configuration
- Verify Firestore rules allow the intended operations

### Call Feature Debugging
- Check ZegoCloud credentials in `zego_config.dart`
- Verify network connectivity before calls
- Test permissions on physical devices (simulators may not work)
- Monitor Firestore call_invitations collection for debugging

### Build Issues
- Run `flutter clean && flutter pub get` for dependency issues
- Check that all required SDKs are installed for target platforms
- Verify `pubspec.yaml` dependency versions compatibility

### Performance Considerations
- Use `const` constructors where possible
- Implement proper stream disposal in BLoCs
- Optimize Firebase queries with proper indexing
- Consider pagination for large message lists

## Environment Setup

### Required Tools
- Flutter SDK (^3.9.0)
- Firebase CLI for deployment
- Platform-specific build tools (Android Studio, Xcode, Visual Studio)
- ZegoCloud account for call functionality

### Initial Setup
1. Run `flutter pub get` to install dependencies
2. Configure Firebase with `flutterfire configure`
3. Set up ZegoCloud credentials in `zego_config.dart`
4. Deploy Firestore rules: `firebase deploy --only firestore:rules`
5. Run the app: `flutter run`

This architecture enables scalable development while maintaining clear separation of concerns and testability throughout the application.