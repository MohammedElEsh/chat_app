# Call Feature Troubleshooting Guide

## Common Issues and Solutions

### 1. **"Package not found" or Import Errors**

**Problem**: `zego_uikit_prebuilt_call` package not found

**Solution**:
```bash
# Run this in your project directory
flutter clean
flutter pub get
```

### 2. **Permission Errors**

**Problem**: Camera or microphone permissions denied

**Solutions**:
- **Android**: Check `android/app/src/main/AndroidManifest.xml` has all required permissions
- **iOS**: Check `ios/Runner/Info.plist` has usage descriptions
- **Runtime**: The app will automatically request permissions when starting a call

### 3. **Call Initialization Errors**

**Problem**: "Failed to initialize call" error

**Possible Causes**:
- Invalid ZegoCloud credentials
- Network connectivity issues
- Device doesn't support required features

**Solutions**:
- Verify AppID and AppSign are correct
- Test on physical device (not simulator)
- Check internet connection

### 4. **Build Errors**

**Problem**: Build fails after adding ZegoCloud dependency

**Solutions**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug  # for Android
flutter build ios --debug  # for iOS
```

### 5. **Dependency Conflicts**

**Problem**: Version conflicts with other packages

**Solution**: Check `pubspec.yaml` for `dependency_overrides` section and ensure compatible versions.

### 6. **Runtime Crashes**

**Problem**: App crashes when starting call

**Solutions**:
- Ensure all required parameters are provided (callID, userID, userName)
- Test on physical device
- Check logs for specific error messages

## Testing Steps

1. **Basic Test**:
   - Open any chat screen
   - Click voice call button (should show permission request)
   - Grant permissions
   - Call interface should appear

2. **Permission Test**:
   - Deny permissions initially
   - App should show permission dialog
   - Navigate to settings and grant permissions
   - Try call again

3. **Error Handling Test**:
   - Disconnect internet
   - Try to start call (should show appropriate error)
   - Reconnect and try again

## Debug Commands

```bash
# Check if package is properly installed
flutter pub deps

# Check for any dependency conflicts
flutter pub outdated

# Clean build for fresh start
flutter clean && flutter pub get

# Build with verbose logging
flutter build apk --debug --verbose
```

## Required Files Modified

✅ `pubspec.yaml` - Added dependency  
✅ `lib/features/call/presentation/pages/call_page.dart` - Main call widget  
✅ `lib/features/call/data/services/call_service.dart` - Permission handling  
✅ `lib/features/chat/presentation/views/chat_app_bar.dart` - Call buttons  
✅ `android/app/src/main/AndroidManifest.xml` - Android permissions  
✅ `ios/Runner/Info.plist` - iOS permissions  

## Contact Support

If issues persist:
1. Check ZegoCloud documentation
2. Verify your ZegoCloud project settings
3. Test on different devices
4. Check device compatibility requirements