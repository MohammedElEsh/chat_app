import 'package:flutter/material.dart';
import '../views/users_show_widget.dart';

class FindUsersPage extends StatelessWidget {
  final String currentUserId;
  final Function(String, Map<String, dynamic>) onUserSelected;

  const FindUsersPage({
    super.key,
    required this.currentUserId,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container( // Added Container for gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C52FF), Color(0xFFC300FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent scaffold
        appBar: AppBar(
          title: const Text(
            'Find Users',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0,
          automaticallyImplyLeading: false, // This removes the default back button
          // Add a custom 'close' button for better UX
        ),
        body: UsersShowWidget(
          currentUserId: currentUserId,
          onUserSelected: onUserSelected,
        ),
      ),
    );
  }
}