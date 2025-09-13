import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../chat/data/services/chat_service.dart';
import 'user_list_tile.dart';

class UsersShowWidget extends StatelessWidget {
  final String currentUserId;
  final Function(String, Map<String, dynamic>) onUserSelected;

  const UsersShowWidget({
    super.key,
    required this.currentUserId,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: ChatService.getAllUsers(), // Directly get all users
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading users',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final userDocs = snapshot.data!.docs
            .where((doc) => doc.id != currentUserId) // Exclude current user
            .toList();

        if (userDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'No other users found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: userDocs.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.white24,
            indent: 72,
          ),
          itemBuilder: (context, index) {
            final userDoc = userDocs[index];
            final userData = userDoc.data() as Map<String, dynamic>;

            final userName = userData['name'] ?? 'User';
            final userEmail = userData['email'] ?? '';
            final userPhotoURL = userData['photoURL'] ?? '';

            return UserListTile(
              userId: userDoc.id,
              userName: userName,
              userEmail: userEmail,
              userPhotoURL: userPhotoURL,
              onTap: () {
                onUserSelected(userDoc.id, userData);
              },
            );
          },
        );
      },
    );
  }
}