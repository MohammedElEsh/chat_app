import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../data/services/upload_service.dart';
import '../../data/services/voice_upload_service.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController messageController;
  final bool isSending;
  final VoidCallback onSendPressed;
  final Function(String)? onImageSent;
  final Function(String)? onVoiceSent;

  const ChatInputField({
    super.key,
    required this.messageController,
    required this.isSending,
    required this.onSendPressed,
    this.onImageSent,
    this.onVoiceSent,
  });
  
  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> with TickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _recordingAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _recordingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.bottomInputGradientStart,
            AppColors.bottomInputGradientEnd,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Camera icon
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => _showImageSourceDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      maxHeight: 80,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                    controller: widget.messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => widget.onSendPressed(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Microphone icon (Recording)
                GestureDetector(
                  onTap: _handleMicrophoneTap,
                  child: AnimatedBuilder(
                    animation: _recordingAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: _isRecording 
                              ? Colors.red.withOpacity(_recordingAnimation.value * 0.8)
                              : Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: _isRecording
                              ? Border.all(
                                  color: Colors.red.withOpacity(_recordingAnimation.value),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: _isRecording ? Colors.white : Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Send button
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: widget.isSending
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                        : Icon(
                      Icons.send,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    onPressed: widget.isSending ? null : widget.onSendPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    if (widget.onImageSent == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'اختيار مصدر الصورة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      label: 'الكاميرا',
                      color: AppColors.primary,
                      onTap: () => _handleCameraUpload(context),
                    ),
                    _buildSourceOption(
                      context,
                      icon: Icons.photo_library,
                      label: 'المعرض',
                      color: Colors.green,
                      onTap: () => _handleGalleryUpload(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCameraUpload(BuildContext context) async {
    Navigator.pop(context); // إغلاق الحوار
    
    if (widget.onImageSent == null) return;

    try {
      // إظهار loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final uploadService = UploadService();
      // حاجة chatId - هيجيب من ال parent widget
      final imageUrl = await uploadService.pickAndUploadImageFromCamera(
        chatId: 'default_chat', // TODO: Get actual chatId from parent
      );

      // إغلاق loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (imageUrl != null) {
        widget.onImageSent!(imageUrl);
      } else {
        _showErrorSnackBar('فشل في رفع الصورة');
      }
    } catch (e) {
      // إغلاق loading
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('خطأ: $e');
      }
    }
  }

  Future<void> _handleGalleryUpload(BuildContext context) async {
    Navigator.pop(context); // إغلاق الحوار
    
    if (widget.onImageSent == null) return;

    try {
      // إظهار loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final uploadService = UploadService();
      final imageUrl = await uploadService.pickAndUploadImageFromGallery(
        chatId: 'default_chat', // TODO: Get actual chatId from parent
      );

      // إغلاق loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (imageUrl != null) {
        widget.onImageSent!(imageUrl);
      } else {
        _showErrorSnackBar('فشل في رفع الصورة');
      }
    } catch (e) {
      // إغلاق loading
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('خطأ: $e');
      }
    }
  }

  /// معالجة ضغط زر الميكروفون
  Future<void> _handleMicrophoneTap() async {
    if (widget.onVoiceSent == null) return;

    if (!_isRecording) {
      // بدء التسجيل
      await _startRecording();
    } else {
      // إيقاف التسجيل ورفع الملف
      await _stopRecordingAndUpload();
    }
  }

  /// بدء التسجيل
  Future<void> _startRecording() async {
    try {
      final started = await VoiceUploadService.startRecording();
      if (started) {
        setState(() {
          _isRecording = true;
        });
        _recordingAnimationController.repeat(reverse: true);
      } else {
        _showErrorSnackBar('فشل في بدء التسجيل');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في بدء التسجيل: $e');
    }
  }

  /// إيقاف التسجيل ورفع الملف
  Future<void> _stopRecordingAndUpload() async {
    try {
      // إظهار loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final voiceUrl = await VoiceUploadService.stopRecordingAndUpload(
        chatId: 'default_chat', // TODO: Get actual chatId from parent
      );

      // إغلاق loading
      if (mounted) {
        Navigator.pop(context);
      }

      // تحديث الحالة
      setState(() {
        _isRecording = false;
      });
      _recordingAnimationController.reset();

      if (voiceUrl != null && voiceUrl.isNotEmpty) {
        widget.onVoiceSent!(voiceUrl);
      } else {
        _showErrorSnackBar('فشل في رفع التسجيل الصوتي');
      }
    } catch (e) {
      // إغلاق loading
      if (mounted) {
        Navigator.pop(context);
      }
      
      // تحديث الحالة
      setState(() {
        _isRecording = false;
      });
      _recordingAnimationController.reset();
      
      _showErrorSnackBar('خطأ في رفع التسجيل: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
