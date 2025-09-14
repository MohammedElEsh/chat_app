# Call Invitation Testing Checklist

## Pre-Testing Setup

### Environment Requirements
- [ ] Two physical devices (Android/iOS)
- [ ] Both devices have internet connectivity
- [ ] Both devices logged into different user accounts
- [ ] App installed and running on both devices
- [ ] Camera and microphone permissions granted

### Build Requirements
- [ ] `flutter pub get` completed successfully
- [ ] App builds without errors
- [ ] No import/dependency issues
- [ ] Firestore rules applied
- [ ] ZegoCloud credentials configured

---

## Core Functionality Tests

### ✅ Voice Call Tests

#### Voice Call - Happy Path
- [ ] User A opens chat with User B
- [ ] User A clicks voice call button (📞)
- [ ] Calling status dialog appears on User A
- [ ] Incoming call dialog appears on User B within 3 seconds
- [ ] Dialog shows correct caller name and "Voice Call" type
- [ ] Countdown timer starts from 30 seconds
- [ ] User B clicks "Accept"
- [ ] Both users enter call session within 5 seconds
- [ ] Audio works bidirectionally
- [ ] Call can be ended by either user

#### Voice Call - Decline
- [ ] User A calls User B
- [ ] User B receives incoming call dialog
- [ ] User B clicks "Decline"
- [ ] User A receives "Call was declined" message
- [ ] Calling dialog closes on User A
- [ ] Incoming dialog closes on User B
- [ ] No call session established

#### Voice Call - Cancel
- [ ] User A calls User B
- [ ] Calling status appears on User A
- [ ] Incoming dialog appears on User B
- [ ] User A clicks "Cancel Call"
- [ ] Calling status closes on User A
- [ ] Incoming dialog closes on User B
- [ ] No call session established

#### Voice Call - Timeout
- [ ] User A calls User B
- [ ] User B sees incoming dialog with countdown
- [ ] Wait full 30 seconds without responding
- [ ] Countdown reaches 0
- [ ] Incoming dialog auto-closes on User B
- [ ] User A sees "Call timed out" message
- [ ] Calling status closes on User A

### ✅ Video Call Tests

#### Video Call - Happy Path
- [ ] User A opens chat with User B
- [ ] User A clicks video call button (📹)
- [ ] Calling status dialog appears on User A
- [ ] Incoming call dialog appears on User B within 3 seconds
- [ ] Dialog shows correct caller name and "Video Call" type
- [ ] Countdown timer starts from 30 seconds
- [ ] User B clicks "Accept"
- [ ] Both users enter video call session within 5 seconds
- [ ] Video feeds appear for both users
- [ ] Audio works bidirectionally
- [ ] Call can be ended by either user

#### Video Call - Decline
- [ ] User A makes video call to User B
- [ ] User B receives incoming video call dialog
- [ ] User B clicks "Decline"
- [ ] User A receives "Call was declined" message
- [ ] Appropriate cleanup occurs

#### Video Call - Cancel
- [ ] User A makes video call to User B
- [ ] User A cancels before User B responds
- [ ] Both dialogs close appropriately
- [ ] No call session established

#### Video Call - Timeout
- [ ] User A makes video call to User B
- [ ] 30-second timeout completes without response
- [ ] Appropriate timeout behavior occurs

---

## Error Handling Tests

### ✅ Permission Tests

#### Camera Permission (Video Calls)
- [ ] Remove camera permission from app settings
- [ ] User A tries video call
- [ ] Permission request dialog appears
- [ ] Select "Deny"
- [ ] Error message: "Camera and microphone permissions required..."
- [ ] "Settings" button opens device settings
- [ ] Grant permission in settings
- [ ] Return to app and retry call
- [ ] Call works normally

#### Microphone Permission (Voice/Video Calls)
- [ ] Remove microphone permission from app settings
- [ ] User A tries voice call
- [ ] Permission request dialog appears
- [ ] Handle deny/grant scenarios
- [ ] Verify appropriate error messages

### ✅ Network Tests

#### No Internet Connection
- [ ] Disable WiFi and mobile data
- [ ] User A tries to make call
- [ ] Error message: "No internet connection..."
- [ ] Call is blocked
- [ ] Re-enable internet
- [ ] Retry call
- [ ] Call works normally

#### Poor Network Conditions
- [ ] Use slow/unstable internet
- [ ] Attempt call invitation
- [ ] Verify retry logic activates
- [ ] Check if fallback to Firestore occurs

### ✅ Authentication Tests

#### User Not Logged In
- [ ] Force logout current user
- [ ] Try to make call
- [ ] Error message: "You must be logged in to make calls"
- [ ] Login and retry
- [ ] Call works normally

#### Invalid User Scenarios
- [ ] User tries to call themselves
- [ ] Error message: "You cannot call yourself"
- [ ] Call blocked appropriately

---

## UI/UX Tests

### ✅ Animation Tests

#### Calling Status Dialog
- [ ] Pulse animation works smoothly
- [ ] "Waiting for answer..." text animates
- [ ] Cancel button is clearly visible
- [ ] Dialog cannot be dismissed by back button

#### Incoming Call Dialog
- [ ] Avatar has pulsing border animation
- [ ] Entry animation (scale) works
- [ ] "Calling..." text has opacity animation
- [ ] Countdown changes color when ≤ 10 seconds
- [ ] Accept/Decline buttons have proper styling
- [ ] Dialog cannot be dismissed by back button

### ✅ Responsive Design
- [ ] Dialogs work on different screen sizes
- [ ] Text is readable on all devices
- [ ] Buttons are properly sized and touchable
- [ ] Animations don't lag on lower-end devices

---

## Performance Tests

### ✅ Resource Management

#### Memory Usage
- [ ] Make multiple calls and check memory usage
- [ ] Verify no memory leaks after calls end
- [ ] Check that timers and listeners are disposed

#### Battery Impact
- [ ] Monitor battery usage during calls
- [ ] Check impact of continuous animations
- [ ] Verify cleanup when app backgrounded

### ✅ Network Usage
- [ ] Monitor data usage during calls
- [ ] Check efficiency of Firestore listeners
- [ ] Verify appropriate retry intervals

---

## Edge Case Tests

### ✅ Multiple Call Scenarios

#### Simultaneous Calls
- [ ] User A calls User B
- [ ] User B calls User A simultaneously
- [ ] Verify system handles gracefully
- [ ] Check for conflicts or duplicate calls

#### Rapid Call Attempts
- [ ] User A makes multiple rapid call attempts
- [ ] Verify rate limiting or queuing
- [ ] Ensure no duplicate invitations

### ✅ App Lifecycle Tests

#### App Backgrounding
- [ ] Make call invitation
- [ ] Background app on receiver
- [ ] Check if invitation persists
- [ ] Return to foreground and respond

#### App Kill/Restart
- [ ] Make call invitation
- [ ] Force-kill receiving app
- [ ] Restart app
- [ ] Verify appropriate cleanup

#### Network Switching
- [ ] Start call on WiFi
- [ ] Switch to mobile data
- [ ] Verify call continuity
- [ ] Check reconnection behavior

---

## Integration Tests

### ✅ Firestore Fallback

#### Zego Service Unavailable
- [ ] Simulate Zego initialization failure
- [ ] Verify automatic fallback to Firestore
- [ ] Test full call flow with fallback
- [ ] Ensure feature parity

#### Database Operations
- [ ] Check Firestore document creation
- [ ] Verify status updates occur
- [ ] Test security rule enforcement
- [ ] Validate cleanup of old invitations

### ✅ Firebase Authentication
- [ ] Test with different user types
- [ ] Verify user ID consistency
- [ ] Check display name handling
- [ ] Test anonymous auth (if supported)

---

## Security Tests

### ✅ Firestore Security Rules

#### Authorized Access
- [ ] User can read own invitations
- [ ] User can read invitations they receive
- [ ] User can create invitations as sender
- [ ] User can update invitations appropriately

#### Unauthorized Access
- [ ] User cannot read others' invitations
- [ ] User cannot create invitations as fake sender
- [ ] User cannot update invitations they don't own
- [ ] User cannot delete any invitations

### ✅ Data Validation
- [ ] Invalid invitation data is rejected
- [ ] Required fields are enforced
- [ ] Status transitions are validated
- [ ] Timestamp accuracy is maintained

---

## Production Readiness Tests

### ✅ Error Logging
- [ ] Verify appropriate error logs are generated
- [ ] Check log levels are appropriate
- [ ] Ensure no sensitive data in logs

### ✅ User Feedback
- [ ] All error messages are user-friendly
- [ ] Success states are clearly indicated
- [ ] Loading states are informative
- [ ] No technical jargon in user-facing text

### ✅ Accessibility
- [ ] Screen reader compatibility
- [ ] High contrast support
- [ ] Large text support
- [ ] Voice control compatibility

---

## Final Validation

### ✅ Cross-Platform Testing
- [ ] Test Android-to-Android calls
- [ ] Test iOS-to-iOS calls  
- [ ] Test Android-to-iOS calls
- [ ] Test iOS-to-Android calls

### ✅ Different Network Types
- [ ] WiFi to WiFi calls
- [ ] Mobile data to mobile data calls
- [ ] Mixed network type calls
- [ ] Poor signal conditions

### ✅ Device Variations
- [ ] High-end devices
- [ ] Mid-range devices
- [ ] Older devices
- [ ] Different screen sizes

---

## Sign-off Checklist

### ✅ Development Complete
- [ ] All features implemented
- [ ] All tests passing
- [ ] Code reviewed
- [ ] Documentation complete

### ✅ Testing Complete
- [ ] All test cases executed
- [ ] Edge cases validated
- [ ] Performance acceptable
- [ ] Security verified

### ✅ Production Ready
- [ ] Error handling comprehensive
- [ ] User experience polished
- [ ] Monitoring in place
- [ ] Rollback plan ready

---

**Testing Notes:**
- Record any issues found during testing
- Note device models and OS versions used
- Document any workarounds needed
- Update test cases based on findings