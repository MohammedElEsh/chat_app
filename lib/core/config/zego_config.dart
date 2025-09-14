class ZegoConfig {
  // ZegoCloud project credentials
  static const int appID = 359830005;
  static const String appSign = "122dd6681b909ed5f3c2e610c6bd744cb52fa66b45479f241b648e5c1311eef4";
  
  // Call invitation settings
  static const int invitationTimeoutSeconds = 30;
  static const String zegoCallIDPrefix = "zego_call";
  
  // Firestore collection names
  static const String callInvitationsCollection = "call_invitations";
  static const String callsCollection = "calls"; // New collection for active calls
  static const String usersCollection = "users";
  
  // Call types
  static const String callTypeVoice = "voice";
  static const String callTypeVideo = "video";
  
  // Call invitation status
  static const String statusPending = "pending";
  static const String statusAccepted = "accepted";
  static const String statusDeclined = "declined";
  static const String statusCancelled = "cancelled";
  static const String statusTimeout = "timeout";
  static const String statusEnded = "ended";
  
  // Call session status (for calls collection)
  static const String callStatusActive = "active";
  static const String callStatusEnded = "ended";
  
  // Call end reasons
  static const String endReasonHangUp = "hangup";
  static const String endReasonDisconnection = "disconnection";
  static const String endReasonError = "error";
  static const String endReasonBackButton = "back_button";
  static const String endReasonAppBackground = "app_background";
  
  // Generate consistent call ID for both users
  static String generateConsistentCallID(String userId1, String userId2) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Sort IDs to ensure same call ID regardless of who initiates
    final sortedIds = [userId1, userId2]..sort();
    return "${sortedIds[0]}_${sortedIds[1]}_$timestamp";
  }
  
  // Generate unique call ID (legacy)
  static String generateCallID(String callerID, String calleeID) {
    return generateConsistentCallID(callerID, calleeID);
  }
  
  // Generate invitation ID
  static String generateInvitationID() {
    return "${zegoCallIDPrefix}_${DateTime.now().millisecondsSinceEpoch}";
  }
  
  // Get participants from call ID
  static List<String> getParticipantsFromCallID(String callId) {
    final parts = callId.split('_');
    if (parts.length >= 2) {
      return [parts[0], parts[1]];
    }
    return [];
  }
}
