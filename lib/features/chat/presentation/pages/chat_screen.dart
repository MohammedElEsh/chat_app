import 'package:flutter/material.dart';
import '../../../../core/utils/assets.dart';
import '../../../../core/utils/constants.dart';
import '../../data/services/chat_service.dart';
import '../../../camera/services/camera_service.dart';
import '../../../voice/services/voice_service.dart';
import '../views/chat_app_bar.dart';
import '../../domain/entities/message_entity.dart';
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
  bool _isRecording = false;
  String _currentBackground = AppAssets.chatBg1;
  Color _chatBubbleColor = AppColors.defaultOutgoingMessageBubble;
  final CameraService _cameraService = CameraService();
  final VoiceService _voiceService = VoiceService();

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

  void _sendImage() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final imageUrl = await _cameraService.pickAndUploadImage();
      if (imageUrl != null) {
        await ChatService.sendMessage(
          chatId: widget.chatId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUserId,
          text: 'Image', // Placeholder text
          type: MessageType.image,
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: $e'),
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false, // Changed to false to avoid overlap issues
      resizeToAvoidBottomInset: false,
      appBar: ChatAppBar(
        otherUserId: widget.otherUserId,
        otherUserName: widget.otherUserName,
        otherUserPhotoURL: widget.otherUserPhotoURL,
        onOptionsPressed: _showChatOptions,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_currentBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
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
              isRecording: _isRecording,
              onSendPressed: _sendMessage,
              onCameraPressed: _sendImage,
              onMicPressed: _handleVoiceRecording,
              onMicReleased: _handleVoiceStop,
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions() {
    // Debug print to verify the method is being called
    print('_showChatOptions called');

    // Check if context is still mounted
    if (!mounted) {
      print('Context not mounted, cannot show options');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      builder: (BuildContext context) {
        print('Building ChatOptionsBottomSheet');
        return ChatOptionsBottomSheet(
          otherUserName: widget.otherUserName,
          onBackgroundChange: () {
            // Navigator.of(context).pop(); // Close the bottom sheet first
            _showBackgroundOptions();
          },
          onChatBoxChange: () {
            // Navigator.of(context).pop(); // Close the bottom sheet first
            _showChatBoxOptions();
          },
          onDeleteChat: () {
            Navigator.of(context).pop();
            // TODO: Delete chat functionality
          },
        );
      },
    ).catchError((error) {
      print('Error showing chat options: $error');
    });
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

  void _handleVoiceRecording() async {
    if (_isSending || _isRecording) return;

    try {
      final started = await _voiceService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleVoiceStop() async {
    if (!_isRecording) return;

    setState(() {
      _isSending = true;
      _isRecording = false;
    });

    try {
      // Stop recording and get file path and duration
      final recordingData = await _voiceService.stopRecording();
      if (recordingData != null) {
        final filePath = recordingData['path'] as String;
        final duration = recordingData['duration'] as int;

        // Upload to Supabase
        final voiceData = await _voiceService.uploadVoiceToSupabase(
          filePath,
          duration,
        );

        // Send message to Firestore
        await ChatService.sendMessage(
          chatId: widget.chatId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUserId,
          text: 'Voice Message', // Placeholder text
          type: MessageType.voice,
          voiceUrl: voiceData['voiceUrl'],
          duration: voiceData['duration'],
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send voice message: $e'),
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
}
