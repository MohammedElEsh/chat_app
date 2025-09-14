# Call Invitation System with ZegoCloud UIKit

## Overview

This implementation provides a comprehensive call invitation/ringing flow for the Flutter chat app using ZegoCloud UIKit with Signaling plugin and Firestore fallback. Users can send voice and video call invitations with Accept/Decline functionality, timeout handling, and cancellation features.

## Features Implemented

### ✅ Core Functionality
- **Dual Invitation System**: ZegoCloud UIKit + Firestore fallback
- **Voice & Video Calls**: 1-on-1 calling with proper UI flows
- **Ringing Interface**: Accept/Decline buttons with caller information
- **Timeout Handling**: 30-second timeout with countdown display
- **Cancellation**: Caller can cancel before callee responds
- **Real-time Sync**: Both users land in same call session

### ✅ User Experience
- **Animated UI**: Pulse animations and smooth transitions
- **Status Feedback**: Clear messaging for call states
- **Permission Management**: Automatic permission requests
- **Network Monitoring**: Connectivity checks before calls
- **Error Handling**: Comprehensive error messages

### ✅ Technical Architecture
- **Service-Based**: Clean separation with CallInvitationService
- **State Management**: Proper lifecycle handling
- **Retry Logic**: Automatic retry for failed operations
- **Security**: Firestore rules for secure invitation management

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── zego_config.dart                    # Configuration constants
│   └── services/
│       └── connectivity_service.dart           # Network monitoring
├── features/
│   └── call/
│       ├── data/services/
│       │   └── call_service.dart               # Permission handling
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── call_page.dart              # Main call interface
│       │   └── widgets/
│       │       ├── incoming_call_dialog.dart   # Ringing UI
│       │       └── calling_status_widget.dart  # Calling status
│       └── services/
│           └── call_invitation_service.dart    # Core invitation logic
```

## Configuration

### ZegoCloud Credentials
```dart
// lib/core/config/zego_config.dart
static const int appID = 359830005;
static const String appSign = "122dd6681b909ed5f3c2e610c6bd744cb52fa66b45479f241b648e5c1311eef4";
```

### Dependencies Added
```yaml
# pubspec.yaml
dependencies:
  zego_uikit_prebuilt_call: ^4.6.6
  zego_uikit_signaling_plugin: ^2.6.9
  permission_handler: ^12.0.1
  # ... existing dependencies
```

### Permissions

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice and video calls</string>
```

## Testing Guide

### Prerequisites
1. Two test devices (physical devices recommended)
2. Both devices logged into different user accounts
3. Internet connection on both devices
4. Camera and microphone permissions granted

### Test Scenarios

#### 1. **Basic Voice Call Flow**
**Steps:**
1. User A opens chat with User B
2. User A clicks voice call button (📞)
3. Verify calling status dialog appears on User A
4. Verify incoming call dialog appears on User B within 2 seconds
5. User B clicks "Accept" 
6. Verify both users enter the same call session
7. Test audio functionality
8. Either user can end the call

**Expected Results:**
- ✅ Calling dialog shows "Calling [Username]..."
- ✅ Incoming dialog shows caller info with countdown
- ✅ Both users connect to same call ID
- ✅ Audio works bidirectionally

#### 2. **Basic Video Call Flow**
**Steps:**
1. User A opens chat with User B
2. User A clicks video call button (📹)
3. Verify calling status dialog appears on User A
4. Verify incoming call dialog appears on User B within 2 seconds
5. User B clicks "Accept"
6. Verify both users enter the same video call session
7. Test video and audio functionality
8. Either user can end the call

**Expected Results:**
- ✅ Video call UI appears for both users
- ✅ Camera permissions requested if needed
- ✅ Video and audio work bidirectionally

#### 3. **Call Decline Flow**
**Steps:**
1. User A calls User B (voice or video)
2. User B clicks "Decline" on incoming call dialog
3. Verify User A receives decline notification
4. Verify calling dialog closes on User A
5. Verify no call session is established

**Expected Results:**
- ✅ User A sees "Call was declined" message
- ✅ No call session created
- ✅ UI returns to normal state

#### 4. **Call Cancel Flow**
**Steps:**
1. User A calls User B
2. Before User B responds, User A clicks "Cancel Call"
3. Verify incoming call dialog disappears on User B
4. Verify calling dialog closes on User A
5. Verify no call session is established

**Expected Results:**
- ✅ User B's incoming call dialog closes
- ✅ User A returns to chat screen
- ✅ No call session created

#### 5. **Timeout Flow**
**Steps:**
1. User A calls User B
2. Wait for 30 seconds without User B responding
3. Verify incoming call dialog automatically closes on User B
4. Verify User A receives timeout notification
5. Verify calling dialog closes on User A

**Expected Results:**
- ✅ Countdown shows decreasing seconds
- ✅ Call times out at 0 seconds
- ✅ User A sees "Call timed out" message
- ✅ UI returns to normal state

#### 6. **Permission Handling**
**Steps:**
1. Remove camera/microphone permissions from app settings
2. User A tries to make a video call
3. Verify permission request dialog appears
4. Deny permissions
5. Verify appropriate error message
6. Grant permissions and retry
7. Verify call proceeds normally

**Expected Results:**
- ✅ Permission dialog appears when needed
- ✅ Clear error message for denied permissions
- ✅ Settings redirect works
- ✅ Call works after permissions granted

#### 7. **Network Error Handling**
**Steps:**
1. Disable internet connection
2. User A tries to make a call
3. Verify network error message appears
4. Re-enable internet
5. Retry call
6. Verify call works normally

**Expected Results:**
- ✅ "No internet connection" error shown
- ✅ Call blocked when offline
- ✅ Call works when online

#### 8. **Firestore Fallback**
**Steps:**
1. Force Zego initialization to fail (airplane mode during init)
2. User A makes a call to User B
3. Verify Firestore fallback is used
4. Verify incoming call still appears on User B
5. Test Accept/Decline functionality

**Expected Results:**
- ✅ Fallback system activates automatically
- ✅ Call invitation still works
- ✅ Accept/Decline functions normally

### Error Scenarios

#### Invalid User Calls
- User tries to call themselves: "You cannot call yourself"
- User not logged in: "You must be logged in to make calls"

#### Network Issues
- No internet: "No internet connection. Please check your network and try again."
- Zego service unavailable: Automatic fallback to Firestore

#### Permission Issues
- Camera denied (video call): Permission dialog with settings redirect
- Microphone denied: Permission dialog with settings redirect

## Firestore Structure

### Call Invitations Collection
```firestore
call_invitations/{invitationId}
├── id: string                    # Unique invitation ID
├── callId: string               # Call room ID for both users
├── fromId: string               # Caller user ID
├── fromName: string             # Caller display name
├── toId: string                 # Callee user ID
├── toName: string               # Callee display name  
├── type: "voice" | "video"      # Call type
├── status: "pending" | "accepted" | "declined" | "cancelled" | "timeout"
├── createdAt: timestamp         # Creation time
└── updatedAt: timestamp         # Last update time
```

### Security Rules
- Users can only read invitations where they are sender or receiver
- Only senders can create and cancel invitations
- Only receivers can accept or decline invitations
- Status and timestamp validation enforced

## Troubleshooting

### Common Issues

#### 1. **"Invitation not received"**
- Check internet connectivity on both devices
- Verify Firebase project configuration
- Check Firestore security rules
- Ensure both users are authenticated

#### 2. **"Permission denied" errors**
- Grant camera and microphone permissions in device settings
- Restart app after permission changes
- Check app-level permission requests

#### 3. **"Call connection failed"**
- Verify ZegoCloud credentials are correct
- Check network connectivity
- Ensure both users are using compatible app versions

#### 4. **"Zego initialization failed"**
- App falls back to Firestore automatically
- Check console logs for specific error details
- Verify ZegoCloud project settings

### Debugging Tools

#### Enable Verbose Logging
```dart
// Add to main.dart for debugging
import 'dart:developer' as developer;

// Enable detailed logs
developer.log('Call invitation debug info');
```

#### Monitor Firestore
1. Open Firebase Console
2. Go to Firestore Database
3. Monitor `call_invitations` collection in real-time
4. Check document creation and status updates

#### Test Zego Connection
```dart
// Test Zego service availability
try {
  await ZegoUIKitPrebuiltCallInvitationService().init(...);
  print('Zego initialized successfully');
} catch (e) {
  print('Zego initialization failed: $e');
}
```

## Performance Considerations

### Optimizations Implemented
- **Connection Pooling**: Reuse Firestore connections
- **Listener Management**: Proper cleanup to prevent memory leaks  
- **Retry Logic**: Smart retry for failed operations
- **Timeout Handling**: Prevent hanging operations
- **Network Monitoring**: Efficient connectivity checks

### Resource Management
- Dispose timers and controllers properly
- Cancel network listeners when not needed
- Clean up animations and controllers
- Manage Firestore subscription lifecycle

## Future Enhancements

### Possible Improvements
- **Push Notifications**: Firebase Cloud Messaging integration
- **Call History**: Store completed calls in Firestore
- **Group Calling**: Multi-user call support
- **Screen Sharing**: Add screen share capability
- **Call Recording**: Record and store calls (with permission)
- **Background Calls**: Handle calls when app is backgrounded

### Integration Points
- **FCM**: For push notifications when app is closed
- **CallKit**: iOS native call interface integration
- **Analytics**: Track call success rates and errors
- **Monitoring**: Real-time call quality metrics

## Console Setup Requirements

### ZegoCloud Console
1. Login to ZegoCloud Console
2. Navigate to Project Settings
3. Ensure these features are enabled:
   - Call invitation
   - Signaling service
   - Audio/Video calling
4. Verify monthly quota limits
5. Check billing status if using paid features

### Firebase Console  
1. Enable Firestore Database
2. Apply security rules from `firestore_security_rules.txt`
3. Enable Authentication
4. (Optional) Enable Cloud Messaging for push notifications

## Conclusion

This implementation provides a robust, production-ready call invitation system with comprehensive error handling, fallback mechanisms, and excellent user experience. The dual approach (ZegoCloud + Firestore) ensures reliability even when primary services are unavailable.

For additional support or questions, refer to:
- ZegoCloud Documentation: https://docs.zegocloud.com/
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Permission Handler: https://pub.dev/packages/permission_handler