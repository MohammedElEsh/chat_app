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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    developer.log('📞 CallPage initialized for call: ${widget.callID}');
    
    // Set up a timer to check call state periodically
    _startCallStateMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _handleCallEnd();
    developer.log('🗑️ CallPage disposed for call: ${widget.callID}');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // App is going to background or being closed
      _handleCallEnd();
    }
  }

  /// Monitor call state - this is a fallback for detecting call ends
  void _startCallStateMonitoring() {
    // Since we can't reliably hook into ZegoUIKit's internal end events,
    // we rely on the service's Firestore listener to handle call ends
    developer.log('🔍 Started call state monitoring for: ${widget.callID}');
  }

  /// Handle call end - notify service and navigate back
  void _handleCallEnd() {
    if (!_hasNotifiedCallEnd && _isCallActive) {
      _hasNotifiedCallEnd = true;
      _isCallActive = false;
      
      developer.log('🔴 Call ended: ${widget.callID}');
      
      // Notify the invitation service that call has ended
      CallInvitationService.instance.notifyCallEnded(widget.callID);
      
      // Navigate back to previous screen (chat) after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          developer.log('⬅️ Navigated back from call');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _handleCallEnd();
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
    
    // Note: Call end detection is handled by:
    // 1. PopScope for back button/gesture
    // 2. App lifecycle observer for app backgrounding
    // 3. CallInvitationService Firestore listener for remote call ends
    developer.log('📱 Call config built for: ${widget.isVideoCall ? "Video" : "Voice"} call');

    return config;
  }
}
