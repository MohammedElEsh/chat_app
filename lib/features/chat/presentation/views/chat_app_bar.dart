import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import '../../../../core/utils/constants.dart';
import '../../../call/services/call_invitation_service.dart';
import '../../../call/presentation/widgets/calling_status_widget.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhotoURL;
  final VoidCallback onOptionsPressed;

  const ChatAppBar({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhotoURL,
    required this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .snapshots(),
          builder: (context, snapshot) {
            bool isOnline = false;
            DateTime? lastSeen;

            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              if (userData != null) {
                isOnline = userData['isOnline'] ?? false;
                if (userData['lastSeen'] != null) {
                  lastSeen = (userData['lastSeen'] as Timestamp).toDate();
                }
              }
            }

            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: otherUserPhotoURL.isNotEmpty
                      ? NetworkImage(otherUserPhotoURL)
                      : null,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: otherUserPhotoURL.isEmpty
                      ? Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isOnline)
                        const Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                          ),
                        )
                      else if (lastSeen != null)
                        Text(
                          'Last seen: ${DateFormat('MMM d, HH:mm').format(lastSeen)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        )
                      else
                        const Text(
                          'Offline',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () => _startVoiceCall(context),
        ),
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () => _startVideoCall(context),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            print('Options button pressed in ChatAppBar');
            onOptionsPressed();
          },
          tooltip: 'Chat options',
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
        ),
      ],
    );
  }

  void _startVoiceCall(BuildContext context) async {
    // Show calling status dialog first
    CallingStatusWidget.show(
      context: context,
      calleeName: otherUserName,
      isVideoCall: false,
      onCancel: () {
        // Handle cancel from caller side
        CallInvitationService.instance.cancelInvitation();
        Navigator.of(context).pop();
      },
    );
    
    // Send the invitation
    final success = await CallInvitationService.instance.sendInvitation(
      calleeId: otherUserId,
      calleeName: otherUserName,
      isVideoCall: false,
      context: context,
    );
    
    if (!success) {
      // Close calling status dialog on failure
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send call invitation'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Success feedback
      developer.log('✅ Voice call invitation sent to $otherUserName');
    }
  }

  void _startVideoCall(BuildContext context) async {
    // Show calling status dialog first
    CallingStatusWidget.show(
      context: context,
      calleeName: otherUserName,
      isVideoCall: true,
      onCancel: () {
        // Handle cancel from caller side
        CallInvitationService.instance.cancelInvitation();
        Navigator.of(context).pop();
      },
    );
    
    // Send the invitation
    final success = await CallInvitationService.instance.sendInvitation(
      calleeId: otherUserId,
      calleeName: otherUserName,
      isVideoCall: true,
      context: context,
    );
    
    if (!success) {
      // Close calling status dialog on failure
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send call invitation'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Success feedback
      developer.log('✅ Video call invitation sent to $otherUserName');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}