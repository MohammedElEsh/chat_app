import 'package:flutter/material.dart';

class UserListTile extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhotoURL;
  final VoidCallback onTap;

  const UserListTile({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhotoURL,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: userPhotoURL.isNotEmpty
              ? NetworkImage(userPhotoURL)
              : null,
          backgroundColor: Colors.white.withOpacity(0.3), // Updated color
          child: userPhotoURL.isEmpty
              ? Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )
              : null,
        ),
        title: Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white, // Updated color
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: userEmail.isNotEmpty
            ? Text(
          userEmail,
          style: const TextStyle(
            color: Colors.white70, // Updated color
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        )
            : null,
        trailing: const Icon(
          Icons.chat_bubble_outline, // Changed icon for better context
          color: Colors.white70, // Updated color
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}