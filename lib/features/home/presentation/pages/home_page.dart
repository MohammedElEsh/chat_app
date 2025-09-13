import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../chat/data/services/chat_service.dart';
import '../views/find_users_page.dart';
import '../views/home_view_body.dart';
import '../views/logout_dialog.dart';

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
                showLogoutConfirmation(context);
              },
            ),
          ],
        ),
        body: HomeViewBody(currentUser: widget.currentUser),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Capture the NavigatorState from the HomeScreen's context before any async operations.
            final navigator = Navigator.of(context);

            navigator.push(
              MaterialPageRoute(
                builder: (context) => FindUsersPage(
                  currentUserId: widget.currentUser.id,
                  onUserSelected: (String otherUserId, Map<String, dynamic> userData) async {
                    // Pop the current screen (FindUsersPage) using its own context.
                    // This is safe as it's before the await.
                    Navigator.of(context).pop();

                    // This is the "async gap".
                    final chatId = await ChatService.createOrGetChat(
                      currentUserId: widget.currentUser.id,
                      otherUserId: otherUserId,
                      otherUserData: userData,
                    );

                    // After the gap, check if the HomeScreen widget is still mounted.
                    if (!mounted) return;

                    // Use the captured 'navigator' which is safe from the async gap.
                    navigator.push(
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
                  },
                ),
              ),
            );
          },
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6C52FF),
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  void showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
  }
}