import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/assets.dart';
import '../../../../core/utils/constants.dart';
import '../../data/services/chat_service.dart';
import '../views/chat_app_bar.dart';
import '../views/chat_input_field.dart';
import '../views/chat_messages_list.dart';
import '../views/chat_options.dart';


class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhotoURL;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhotoURL,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  String _currentBackground = AppAssets.chatBg1;
  Color _chatBubbleColor = AppColors.defaultOutgoingMessageBubble;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await ChatService.sendMessage(
        chatId: widget.chatId,
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        text: text,
      );

      _messageController.clear();

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_currentBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: ChatAppBar(
          otherUserId: widget.otherUserId,
          otherUserName: widget.otherUserName,
          otherUserPhotoURL: widget.otherUserPhotoURL,
          onOptionsPressed: _showChatOptions,
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: ChatMessagesList(
                chatId: widget.chatId,
                currentUserId: widget.currentUserId,
                scrollController: _scrollController,
                otherUserName: widget.otherUserName,
                chatBubbleColor: _chatBubbleColor,
              ),
            ),
            // Message input
            ChatInputField(
              messageController: _messageController,
              isSending: _isSending,
              onSendPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatOptionsBottomSheet(
        otherUserName: widget.otherUserName,
        onBackgroundChange: () => _showBackgroundOptions(),
        onChatBoxChange: () => _showChatBoxOptions(),
        onDeleteChat: () {
          context.pop();
          // TODO: Delete chat functionality
        },
      ),
    );
  }

  void _showBackgroundOptions() {
    showDialog(
      context: context,
      builder: (context) => BackgroundOptionsDialog(
        currentBackground: _currentBackground,
        onBackgroundSelected: (background) {
          setState(() {
            _currentBackground = background;
          });
        },
      ),
    );
  }

  void _showChatBoxOptions() {
    showDialog(
      context: context,
      builder: (context) => ChatBoxOptionsDialog(
        currentColor: _chatBubbleColor,
        onColorSelected: (color) {
          setState(() {
            _chatBubbleColor = color;
          });
        },
      ),
    );
  }
}