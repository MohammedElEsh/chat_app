import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 359830005,
      appSign: "122dd6681b909ed5f3c2e610c6bd744cb52fa66b45479f241b648e5c1311eef4",
      userID: currentUserId,
      userName: currentUserName,
      callID: callID,
      config: isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }
}