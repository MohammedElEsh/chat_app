import 'package:flutter/material.dart';
import '../../../../core/utils/assets.dart';
import '../../../../core/utils/constants.dart';

class ChatOptionsBottomSheet extends StatelessWidget {
  final String otherUserName;
  final VoidCallback onBackgroundChange;
  final VoidCallback onChatBoxChange;
  final VoidCallback onDeleteChat;

  const ChatOptionsBottomSheet({
    super.key,
    required this.otherUserName,
    required this.onBackgroundChange,
    required this.onChatBoxChange,
    required this.onDeleteChat,
  });

  @override
  Widget build(BuildContext context) {
    print('ChatOptionsBottomSheet build called');
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF1A0371)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Chat with $otherUserName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.wallpaper, color: Colors.white),
                  title: const Text(
                    'Change Background',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onBackgroundChange();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble, color: Colors.white),
                  title: const Text(
                    'Change Chat Box',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onChatBoxChange();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.white70),
                  title: const Text(
                    'Delete Chat',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onDeleteChat();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundOptionsDialog extends StatelessWidget {
  final String currentBackground;
  final Function(String) onBackgroundSelected;

  const BackgroundOptionsDialog({
    super.key,
    required this.currentBackground,
    required this.onBackgroundSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Background'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              onBackgroundSelected(AppAssets.chatBg1);
              Navigator.of(context).pop();
            },
            child: Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentBackground == AppAssets.chatBg1
                      ? Colors.blue
                      : Colors.grey,
                  width: currentBackground == AppAssets.chatBg1 ? 3 : 1,
                ),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.chatBg1),
                  fit: BoxFit.cover,
                ),
              ),
              child: currentBackground == AppAssets.chatBg1
                  ? const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 24,
                ),
              )
                  : null,
            ),
          ),
          InkWell(
            onTap: () {
              onBackgroundSelected(AppAssets.chatBg2);
              Navigator.of(context).pop();
            },
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentBackground == AppAssets.chatBg2
                      ? Colors.blue
                      : Colors.grey,
                  width: currentBackground == AppAssets.chatBg2 ? 3 : 1,
                ),
                image: const DecorationImage(
                  image: AssetImage(AppAssets.chatBg2),
                  fit: BoxFit.cover,
                ),
              ),
              child: currentBackground == AppAssets.chatBg2
                  ? const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                  size: 24,
                ),
              )
                  : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class ChatBoxOptionsDialog extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ChatBoxOptionsDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Chat Box Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildColorOption(context, AppColors.primary),
              _buildColorOption(context, AppColors.accentPink),
              _buildColorOption(context, AppColors.accentRed),
              _buildColorOption(context, AppColors.accentYellow),
              _buildColorOption(context, AppColors.accentGreen),
              _buildColorOption(context, AppColors.accentCyan),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildColorOption(BuildContext context, Color color) {
    return InkWell(
      onTap: () {
        onColorSelected(color);
        Navigator.of(context).pop();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: currentColor == color
                ? Colors.white
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: currentColor == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}