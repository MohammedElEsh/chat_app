import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_hasText && !widget.isLoading) {
      final message = _controller.text.trim();
      _controller.clear();
      setState(() {
        _hasText = false;
      });
      widget.onSendMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.grey.shade600,
                ),
                onPressed: widget.isLoading ? null : () {
                  // TODO: Implement attachment functionality
                  _showAttachmentOptions();
                },
              ),
            ),
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: widget.isLoading ? null : (_) => _sendMessage(),
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button or voice button
            Container(
              decoration: BoxDecoration(
                color: _hasText 
                    ? Colors.blue.shade500 
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: widget.isLoading
                  ? Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _hasText ? Icons.send : Icons.mic,
                        color: _hasText ? Colors.white : Colors.grey.shade600,
                      ),
                      onPressed: _hasText 
                          ? _sendMessage 
                          : () {
                              // TODO: Implement voice recording
                              _showVoiceRecordingDialog();
                            },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Share Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _AttachmentOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement gallery picker
                        },
                      ),
                      _AttachmentOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement camera
                        },
                      ),
                      _AttachmentOption(
                        icon: Icons.insert_drive_file,
                        label: 'Document',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement document picker
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceRecordingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Message'),
        content: const Text('Voice recording feature will be implemented soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
