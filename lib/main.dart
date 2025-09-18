import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/utils/constants.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_with_email.dart';
import 'features/auth/domain/usecases/register_with_email.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/chat/data/datasources/firebase_chat_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/data/repositories/chats_repository_impl.dart';
import 'features/chat/data/datasources/firebase_chats_datasource.dart';
import 'features/chat/domain/usecases/send_message.dart';
import 'features/chat/domain/usecases/get_messages.dart';
import 'features/chat/domain/usecases/get_message_history.dart';
import 'features/chat/domain/usecases/get_messages_stream.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/home/domain/usecases/get_chats_for_user.dart' as home_use_cases;
import 'features/call/services/call_invitation_service.dart';
import 'core/services/connectivity_service.dart';
import 'firebase_options.dart';

// Global navigator key for app-wide navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Supabase - مؤقتاً مُعطل لحين إضافة البيانات الصحيحة
  // await SupabaseConfig.initialize();
  
  // Initialize services
  ConnectivityService.instance.initialize();
  
  // Initialize call invitation service after Firebase auth is ready
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      CallInvitationService.instance.initialize();
    } else {
      CallInvitationService.instance.dispose();
    }
  });
  
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Manually instantiate dependencies
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    final authDataSource = FirebaseAuthDataSourceImpl(firebaseAuth, firestore);
    final authRepository = AuthRepositoryImpl(authDataSource);
    
    final loginWithEmail = LoginWithEmail(authRepository);
    final registerWithEmail = RegisterWithEmail(authRepository);
    final logout = Logout(authRepository);
    
    final authBloc = AuthBloc(
      authRepository,
      loginWithEmail,
      registerWithEmail,
      logout,
    );

    // Chat dependencies
    final chatDataSource = FirebaseChatDataSourceImpl(firestore, firebaseAuth);
    final chatRepository = ChatRepositoryImpl(chatDataSource);
    
    final sendMessage = SendMessage(chatRepository);
    final getMessages = GetMessages(chatRepository);
    final getMessageHistory = GetMessageHistory(chatRepository);
    final getMessagesStream = GetMessagesStream(chatRepository);
    
    final chatBloc = ChatBloc(
      sendMessage,
      getMessages,
      getMessageHistory,
      getMessagesStream,
    );

    // Chats (Home) dependencies
    final chatsDataSource = FirebaseChatsDataSourceImpl(firestore);
    final chatsRepository = ChatsRepositoryImpl(chatsDataSource);
    
    final getChatsForUser = home_use_cases.GetChatsForUser(chatsRepository);

    return MultiProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => authBloc..add(const AuthCheckRequested()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => chatBloc,
        ),
        Provider<home_use_cases.GetChatsForUser>(
          create: (context) => getChatsForUser,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthAuthenticated) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
