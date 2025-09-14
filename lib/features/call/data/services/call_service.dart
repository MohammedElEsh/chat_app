import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CallService {
  /// Request necessary permissions for voice and video calls
  static Future<bool> requestCallPermissions({required bool isVideoCall}) async {
    final List<Permission> permissions = [
      Permission.microphone,
    ];

    if (isVideoCall) {
      permissions.add(Permission.camera);
    }

    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Check if all required permissions are granted
    bool allGranted = true;
    for (Permission permission in permissions) {
      if (statuses[permission] != PermissionStatus.granted) {
        allGranted = false;
        break;
      }
    }

    return allGranted;
  }

  /// Show permission denied dialog
  static void showPermissionDeniedDialog(BuildContext context, {required bool isVideoCall}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: Text(
          isVideoCall
              ? 'Camera and microphone permissions are required for video calls. Please grant these permissions in settings.'
              : 'Microphone permission is required for voice calls. Please grant this permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  /// Generate a unique call ID
  static String generateCallId(String currentUserId, String otherUserId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // Sort user IDs to ensure consistent call ID regardless of who initiates
    final sortedIds = [currentUserId, otherUserId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}_$timestamp';
  }

  /// Validate call parameters
  static bool validateCallParameters({
    required String callId,
    required String currentUserId,
    required String currentUserName,
  }) {
    return callId.isNotEmpty && 
           currentUserId.isNotEmpty && 
           currentUserName.isNotEmpty;
  }
}