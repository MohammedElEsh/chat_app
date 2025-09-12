import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../chat/data/services/chat_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return HomeScreen(currentUser: authState.user);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final dynamic currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Create or update user document
    ChatService.createOrUpdateUser(widget.currentUser);
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C52FF), Color(0xFFC300FF)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Chats',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
        body: _buildChatList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: const Text('Find Users'),
                    backgroundColor: const Color(0xFF6C52FF),
                  ),
                  body: UserSearchWidget(
                    currentUserId: widget.currentUser.id,
                    onUserSelected: (String otherUserId, Map<String, dynamic> userData) async {
                      Navigator.of(context).pop(); // Close the search screen
                      // Create or get chat with selected user
                      final chatId = await ChatService.createOrGetChat(
                        currentUserId: widget.currentUser.id,
                        otherUserId: otherUserId,
                        otherUserData: userData,
                      );

                      // Navigate to chat screen
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              chatId: chatId,
                              currentUserId: widget.currentUser.id,
                              otherUserId: otherUserId,
                              otherUserName: userData['name'] ?? 'User',
                              otherUserPhotoURL: userData['photoURL'] ?? '',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF6C52FF),
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: ChatService.getUserChats(widget.currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading chats',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading chats...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No chats yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the + button to find users and start chatting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final chatDocs = snapshot.data!.docs;

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh is handled automatically by the stream
          },
          color: const Color(0xFF6C52FF),
          backgroundColor: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatDocs.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.white24,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final chatDoc = chatDocs[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;

              final otherParticipant = ChatService.getOtherParticipant(
                chatData,
                widget.currentUser.id,
              );

              if (otherParticipant == null) {
                return const SizedBox.shrink();
              }

              final otherUserName = otherParticipant['name'] ?? 'Unknown User';
              final otherUserPhotoURL = otherParticipant['photoURL'] ?? '';
              final otherUserId = otherParticipant['id'] ?? '';
              final lastMessage = chatData['lastMessage'] ?? '';
              final lastMessageTime = chatData['lastMessageTime'] as Timestamp?;

              return ChatListTile(
                chatId: chatDoc.id,
                otherUserId: otherUserId,
                otherUserName: otherUserName,
                otherUserPhotoURL: otherUserPhotoURL,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatDoc.id,
                        currentUserId: widget.currentUser.id,
                        otherUserId: otherUserId,
                        otherUserName: otherUserName,
                        otherUserPhotoURL: otherUserPhotoURL,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }


}

class ChatListTile extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhotoURL;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhotoURL,
    required this.lastMessage,
    required this.lastMessageTime,
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
          backgroundImage: otherUserPhotoURL.isNotEmpty
              ? NetworkImage(otherUserPhotoURL)
              : null,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: otherUserPhotoURL.isEmpty
              ? Text(
            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          )
              : null,
        ),
        title: Text(
          otherUserName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastMessage.isNotEmpty ? lastMessage : 'No messages yet',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: lastMessageTime != null
            ? Text(
          _formatTimestamp(lastMessageTime!),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        )
            : null,
        onTap: onTap,
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays == 0) {
      // Same day - show time
      return DateFormat('HH:mm').format(messageTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week - show day name
      return DateFormat('EEEE').format(messageTime);
    } else if (difference.inDays < 365) {
      // This year - show month and day
      return DateFormat('MMM d').format(messageTime);
    } else {
      // Different year - show year
      return DateFormat('MMM d, yyyy').format(messageTime);
    }
  }
}


void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign Out'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

class UserSearchWidget extends StatefulWidget {
  final String currentUserId;
  final Function(String, Map<String, dynamic>) onUserSelected;

  const UserSearchWidget({
    super.key,
    required this.currentUserId,
    required this.onUserSelected,
  });

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.transparent,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users by name...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        // Search results
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _searchQuery.isEmpty
                ? ChatService.getAllUsers()
                : ChatService.searchUsers(_searchQuery),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      const Text(
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
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty ? 'No users found' : 'No users match your search',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final userDocs = snapshot.data!.docs
                  .where((doc) => doc.id != widget.currentUserId) // Exclude current user
                  .toList();

              if (userDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No other users found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
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
                  color: Colors.grey.shade200,
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
                      widget.onUserSelected(userDoc.id, userData);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

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
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: userPhotoURL.isNotEmpty
            ? NetworkImage(userPhotoURL)
            : null,
        backgroundColor: Colors.blue.shade200,
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
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: userEmail.isNotEmpty
          ? Text(
        userEmail,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      )
          : null,
      trailing: Icon(
        Icons.chat,
        color: Colors.blue.shade400,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
