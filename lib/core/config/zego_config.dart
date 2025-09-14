class ZegoConfig {
  // ZegoCloud project credentials
  static const int appID = 359830005;
  static const String appSign = "122dd6681b909ed5f3c2e610c6bd744cb52fa66b45479f241b648e5c1311eef4";
  
  // Call invitation settings
  static const int invitationTimeoutSeconds = 30;
  static const String zegoCallIDPrefix = "zego_call";
  
  // Firestore collection names for fallback
  static const String callInvitationsCollection = "call_invitations";
  static const String usersCollection = "users";
  
  // Call types
  static const String callTypeVoice = "voice";
  static const String callTypeVideo = "video";
  
  // Invitation status
  static const String statusPending = "pending";
  static const String statusAccepted = "accepted";
  static const String statusDeclined = "declined";
  static const String statusCancelled = "cancelled";
  static const String statusTimeout = "timeout";
  static const String statusEnded = "ended";
  
  // Generate unique call ID
  static String generateCallID(String callerID, String calleeID) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Sort IDs for consistent call rooms
    final sortedIds = [callerID, calleeID]..sort();
    return "${sortedIds[0]}_${sortedIds[1]}_$timestamp";
  }
  
  // Generate invitation ID
  static String generateInvitationID() {
    return "${zegoCallIDPrefix}_${DateTime.now().millisecondsSinceEpoch}";
  }
}