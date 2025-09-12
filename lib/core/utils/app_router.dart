import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../main.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  
  // GoRouter configuration
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: chat,
        name: 'chat',
        builder: (context, state) {
          final Map<String, dynamic> chatData = state.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            chatId: chatData['chatId'] ?? '',
            currentUserId: chatData['currentUserId'] ?? '',
            otherUserId: chatData['otherUserId'] ?? '',
            otherUserName: chatData['otherUserName'] ?? '',
            otherUserPhotoURL: chatData['otherUserPhotoURL'] ?? '',
          );
        },
      ),
    ],
  );
  
  // For backward compatibility
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // This method is kept for backward compatibility
    // It should be removed once all navigation is migrated to GoRouter
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Please use GoRouter for navigation'),
        ),
      ),
    );
  }
}