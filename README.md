# Chat App - Codebase Index

## 📋 Project Overview
A comprehensive Flutter chat application with real-time messaging, voice calls, and multimedia support. Built using Clean Architecture principles with Firebase backend integration.

**Repository**: https://github.com/MohammedElEsh/chat_app.git  
**Latest Commit**: 284a4683ed9b520bdb0a65e0a211e3cd5fef1fcc

---

## 🏗️ Architecture & Design Patterns

### Clean Architecture Implementation
- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: UI components, BLoC state management, and pages

### State Management
- **Primary**: Flutter BLoC pattern for complex state management
- **Secondary**: Provider for dependency injection
- **Global Navigation**: GlobalKey<NavigatorState> for app-wide navigation

---

## 📦 Dependencies & Technologies

### 🔥 Firebase Services
- `firebase_core: ^4.1.0` - Core Firebase functionality
- `firebase_auth: ^6.0.2` - Authentication services
- `cloud_firestore: ^6.0.1` - NoSQL database
- `firebase_storage: ^13.0.1` - File storage
- `firebase_messaging: ^16.0.1` - Push notifications

### 📊 State Management & Architecture
- `flutter_bloc: ^9.1.1` - BLoC pattern implementation
- `equatable: ^2.0.7` - Value equality for state objects
- `provider: ^6.1.5+1` - Dependency injection
- `dartz: ^0.10.1` - Functional programming utilities

### 🧭 Navigation & Routing
- `go_router: ^16.2.1` - Declarative routing

### 🎨 Media & Communication
- `image_picker: ^1.2.0` - Image selection
- `flutter_image_compress: ^2.4.0` - Image compression
- `record: ^5.0.4` - Audio recording
- `voice_message_package: ^2.2.1` - Voice message UI
- `just_audio: ^0.9.36` - Audio playback

### ☁️ Real-time Communication
- `supabase_flutter: ^2.10.1` - Additional backend services
- `zego_uikit_prebuilt_call: ^4.18.3` - Video/voice calling
- `zego_uikit_signaling_plugin: ^2.8.17` - Call signaling

### 🔐 Permissions & Storage
- `permission_handler: ^12.0.1` - Device permissions
- `shared_preferences: ^2.5.3` - Local key-value storage
- `path_provider: ^2.1.5` - File system paths

### 🛠 Utilities
- `intl: ^0.19.0` - Internationalization
- `uuid: ^4.5.1` - Unique identifier generation

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & dependency injection
├── firebase_options.dart       # Firebase configuration
├── core/                       # Shared utilities and services
│   ├── config/
│   │   └── zego_config.dart    # Zego SDK configuration
│   ├── errors/
│   │   └── failures.dart       # Error handling abstractions
│   ├── services/
│   │   └── connectivity_service.dart  # Network connectivity
│   └── utils/
│       ├── app_router.dart     # Navigation routing
│       ├── assets.dart         # Asset path constants
│       ├── constants.dart      # App-wide constants & colors
│       └── validators.dart     # Input validation utilities
└── features/                   # Feature-based modules
    ├── auth/                   # Authentication feature
    ├── chat/                   # Chat messaging feature
    ├── home/                   # Home/chat list feature
    ├── call/                   # Voice/video calling feature
    ├── camera/                 # Camera functionality
    └── voice/                  # Voice message feature
```

---

## 🎯 Feature Modules

### 🔐 Authentication (`features/auth/`)
**Purpose**: User registration, login, and authentication management

**Architecture**:
```
auth/
├── data/
│   ├── datasources/
│   │   └── firebase_auth_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_with_email.dart
│       ├── logout.dart
│       └── register_with_email.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    ├── views/
    │   ├── login/          # Login UI components
    │   └── register/       # Registration UI components
    └── widgets/
        ├── custom_button.dart
        └── custom_text_field.dart
```

**Key Components**:
- Firebase Authentication integration
- Email/password authentication
- BLoC state management for auth states
- Custom UI components for forms

### 💬 Chat (`features/chat/`)
**Purpose**: Real-time messaging, message history, and chat management

**Architecture**:
```
chat/
├── data/
│   ├── datasources/
│   │   ├── firebase_chat_datasource.dart
│   │   └── firebase_chats_datasource.dart
│   ├── models/
│   │   ├── chat_model.dart
│   │   └── message_model.dart
│   ├── repositories/
│   │   ├── chat_repository_impl.dart
│   │   └── chats_repository_impl.dart
│   └── services/
│       └── chat_service.dart
├── domain/
│   ├── entities/
│   │   ├── chat_entity.dart
│   │   └── message_entity.dart
│   ├── enums/              # Message types, status enums
│   ├── repositories/
│   │   ├── chat_repository.dart
│   │   └── chats_repository.dart
│   └── usecases/
│       ├── create_chat_if_not_exists.dart
│       ├── get_chats_for_user.dart
│       ├── get_message_history.dart
│       ├── get_messages.dart
│       └── send_message.dart
└── presentation/
    ├── bloc/
    │   ├── chat_bloc.dart
    │   ├── chat_event.dart
    │   └── chat_state.dart
    ├── pages/
    │   └── chat_screen.dart
    ├── views/
    │   ├── chat_app_bar.dart
    │   ├── chat_input_field.dart
    │   ├── chat_messages_list.dart
    │   ├── chat_options.dart
    │   └── message_bubble.dart
    └── widgets/
        ├── chat_input.dart
        └── message_bubble.dart
```

**Key Features**:
- Real-time messaging with Firestore
- Message history and pagination
- Multiple message types support
- Custom message bubbles and input fields

### 🏠 Home (`features/home/`)
**Purpose**: Chat list, user discovery, and navigation hub

**Architecture**:
```
home/
├── domain/
│   └── usecases/
│       └── get_chats_for_user.dart
└── presentation/
    ├── bloc/
    │   ├── home_bloc.dart
    │   ├── home_event.dart
    │   └── home_state.dart
    ├── pages/
    │   └── home_page.dart
    ├── views/
    │   ├── chat_list_tile.dart
    │   ├── chat_list.dart
    │   ├── find_users_page.dart
    │   ├── home_view_body.dart
    │   ├── logout_dialog.dart
    │   ├── user_list_tile.dart
    │   └── users_show_widget.dart
    └── widgets/
        └── chat_list_item.dart
```

**Key Features**:
- Chat list with recent conversations
- User discovery and search
- Navigation to chat screens
- Logout functionality

### 📞 Call (`features/call/`)
**Purpose**: Voice and video calling functionality

**Architecture**:
```
call/
├── presentation/
│   ├── pages/
│   │   └── call_page.dart
│   └── widgets/
│       ├── calling_status_widget.dart
│       └── incoming_call_dialog.dart
└── services/
    ├── call_invitation_service.dart
    └── call_service.dart
```

**Key Features**:
- Zego SDK integration for calls
- Call invitation system
- Incoming call notifications
- Call status management

### 📷 Camera (`features/camera/`)
**Purpose**: Camera functionality for media capture

**Architecture**:
```
camera/
└── services/
    └── camera_service.dart
```

### 🎤 Voice (`features/voice/`)
**Purpose**: Voice message recording and playback

---

## 🎨 UI/UX Design System

### Color Palette
```dart
class AppColors {
  static const Color primary = Color(0xFF6C52FF);           // Primary purple
  static const Color secondary = Color(0xFFC300FF);         // Secondary purple
  static const Color accentPink = Color(0xFFC5048E);        // Pink accent
  static const Color accentRed = Color(0xFFFF5852);         // Red accent
  static const Color accentYellow = Color(0xFFFFDD00);      // Yellow accent
  static const Color accentGreen = Color(0xFF009022);       // Green accent
  static const Color accentCyan = Color(0xFF00A4B6);        // Cyan accent
  
  // Gradients
  static const Color bottomInputGradientStart = Color(0xFF6C52FF);
  static const Color bottomInputGradientEnd = Color(0xFFC300FF);
  
  // Chat bubbles
  static const Color incomingMessageBubble = Colors.white;
  static const Color defaultOutgoingMessageBubble = Color(0xFF6C52FF);
}
```

### Assets Structure
```
assets/
├── images/
│   ├── chat_bg_1.png          # Chat background option 1
│   └── chat_bg_2.png          # Chat background option 2
└── logo/
    └── app_logo.png           # Application logo
```

---

## 🔧 Core Services & Utilities

### Services
- **ConnectivityService**: Network connectivity monitoring
- **CallInvitationService**: Manages call invitations and notifications
- **CallService**: Core calling functionality
- **CameraService**: Camera operations
- **ChatService**: Chat-related business logic

### Utilities
- **AppRouter**: Navigation and routing configuration
- **Assets**: Asset path constants
- **Constants**: App-wide constants and color definitions
- **Validators**: Input validation functions

### Error Handling
- **Failures**: Abstract failure classes for error handling
- Functional programming approach with `dartz` package

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ^3.9.0
- Firebase project setup
- Zego account for calling features

### Installation
1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase (firebase_options.dart)
4. Configure Zego SDK (zego_config.dart)
5. Run `flutter run`

### Build Configuration
- **Android**: Min SDK 21, includes Google Services
- **iOS**: Standard iOS configuration
- **Web**: PWA support with manifest.json

---

## 📱 Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 🧪 Testing
- **Unit Tests**: `test/widget_test.dart`
- **Dev Dependencies**:
    - `flutter_test`
    - `mocktail: ^1.0.4`
    - `bloc_test: ^10.0.0`

---

## 📝 Development Notes

### Dependency Overrides
The project includes specific dependency overrides to resolve version conflicts:
- `just_audio: ^0.9.36` - Unified version for Zego & Voice packages
- `permission_handler: ^12.0.1` - Consistent permissions handling
- `record_linux: 1.2.1` - Linux recording support

### Architecture Decisions
1. **Clean Architecture**: Separation of concerns with clear layer boundaries
2. **BLoC Pattern**: Predictable state management
3. **Repository Pattern**: Abstraction of data sources
4. **Use Cases**: Single responsibility business logic
5. **Dependency Injection**: Manual DI in main.dart for explicit control

### Firebase Integration
- Authentication with email/password
- Firestore for real-time messaging
- Firebase Storage for media files
- Firebase Messaging for push notifications

This codebase follows Flutter best practices and maintains a scalable, maintainable architecture suitable for a production chat application.
