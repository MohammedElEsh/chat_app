import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/constants.dart';
import '../../../call/presentation/pages/call_page.dart';
import '../../../call/data/services/call_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          onPressed: onOptionsPressed,
        ),
      ],
    );
  }

  void _startVoiceCall(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showAuthError(context);
      return;
    }

    final callID = CallService.generateCallId(currentUser.uid, otherUserId);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallPage(
          callID: callID,
          currentUserId: currentUser.uid,
          currentUserName: currentUser.displayName ?? otherUserName,
          isVideoCall: false,
        ),
      ),
    );
  }

  void _startVideoCall(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showAuthError(context);
      return;
    }

    final callID = CallService.generateCallId(currentUser.uid, otherUserId);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallPage(
          callID: callID,
          currentUserId: currentUser.uid,
          currentUserName: currentUser.displayName ?? otherUserName,
          isVideoCall: true,
        ),
      ),
    );
  }

  void _showAuthError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You must be logged in to make calls'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}