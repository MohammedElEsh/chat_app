import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'dart:developer' as developer;
import '../../../../core/config/zego_config.dart';
import '../../services/call_invitation_service.dart';

class CallPage extends StatefulWidget {
  final String callID;
  final String currentUserId;
  final String currentUserName;
  final bool isVideoCall;

  const CallPage({
    super.key,
    required this.callID,
    required this.currentUserId,
    required this.currentUserName,
    this.isVideoCall = true,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> with WidgetsBindingObserver {
  bool _hasNotifiedCallEnd = false;
  bool _isCallActive = true;
  bool _hasNavigatedBack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    developer.log('📞 CallPage initialized for call: ${widget.callID}');
    
    // Register this page with the call invitation service for call end handling
    CallInvitationService.instance.registerCallPage(widget.callID, _handleExternalCallEnd);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CallInvitationService.instance.unregisterCallPage(widget.callID);
    _handleCallEnd(ZegoConfig.endReasonDisconnection);
    developer.log('🗑️ CallPage disposed for call: ${widget.callID}');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // App is going to background or being closed
      _handleCallEnd(ZegoConfig.endReasonAppBackground);
    }
  }

  /// Handle external call end from other user (called by service)
  void _handleExternalCallEnd() {
    if (_hasNavigatedBack) return;
    _hasNavigatedBack = true;
    
    developer.log('📡 External call end received for: ${widget.callID}');
    
    // Navigate back immediately without calling notifyCallEnded
    // (the other user already ended the call)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNavigateBack('external call end');
    });
  }

  /// Safe navigation helper with comprehensive checks
  void _safeNavigateBack(String reason) {
    try {
      if (!mounted) {
        developer.log('⚠️ Cannot navigate: Widget not mounted ($reason)');
        return;
      }
      
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
        developer.log('⬅️ Navigated back from $reason');
      } else {
        developer.log('⚠️ Cannot navigate: No route to pop ($reason)');
      }
    } catch (e) {
      developer.log('❌ Navigation failed ($reason): $e');
    }
  }
  
  /// Handle call end - notify service and navigate back
  void _handleCallEnd(String endReason) {
    if (_hasNotifiedCallEnd || !_isCallActive || _hasNavigatedBack) return;
    
    _hasNotifiedCallEnd = true;
    _isCallActive = false;
    _hasNavigatedBack = true;
    
    developer.log('🔴 Call ended: ${widget.callID}, reason: $endReason');
    
    // Notify the invitation service that call has ended
    CallInvitationService.instance.notifyCallEnded(widget.callID, endReason: endReason);
    
    // Navigate back to previous screen (chat) after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _safeNavigateBack('call end ($endReason)');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleCallEnd(ZegoConfig.endReasonBackButton);
        }
      },
      child: ZegoUIKitPrebuiltCall(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: widget.currentUserId,
        userName: widget.currentUserName,
        callID: widget.callID,
        config: _buildCallConfig(),
      ),
    );
  }

  /// Build call configuration with working v4.6.6 API
  ZegoUIKitPrebuiltCallConfig _buildCallConfig() {
    final config = widget.isVideoCall
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    // Configure bottom menu bar
    config.bottomMenuBar = ZegoCallBottomMenuBarConfig(
      buttons: [
        ZegoCallMenuBarButtonName.toggleCameraButton,
        ZegoCallMenuBarButtonName.switchCameraButton,
        ZegoCallMenuBarButtonName.hangUpButton,
        ZegoCallMenuBarButtonName.toggleMicrophoneButton,
      ],
    );

    // Configure top menu bar
    config.topMenuBar = ZegoCallTopMenuBarConfig(
      buttons: [
        ZegoCallMenuBarButtonName.minimizingButton,
      ],
    );

    // Enable basic features
    config.turnOnCameraWhenJoining = widget.isVideoCall;
    config.turnOnMicrophoneWhenJoining = true;
    config.useSpeakerWhenJoining = widget.isVideoCall;
    
    // Note: ZegoUIKit hang up button detection is not available in this API version
    // We rely on other methods for comprehensive call end detection
    
    // Note: Call end detection is handled by:
    // 1. PopScope for back button/gesture
    // 2. App lifecycle observer for app backgrounding
    // 3. CallInvitationService Firestore listener for remote call ends
    // 4. Widget disposal when page is closed
    developer.log('📱 Call config built for: ${widget.isVideoCall ? "Video" : "Voice"} call');

    return config;
  }
}
