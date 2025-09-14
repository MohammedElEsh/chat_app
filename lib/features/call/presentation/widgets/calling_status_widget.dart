import 'package:flutter/material.dart';
import '../../services/call_invitation_service.dart';

class CallingStatusWidget extends StatefulWidget {
  final String calleeName;
  final bool isVideoCall;
  final VoidCallback? onCancel;

  const CallingStatusWidget({
    super.key,
    required this.calleeName,
    required this.isVideoCall,
    this.onCancel,
  });

  static void show({
    required BuildContext context,
    required String calleeName,
    required bool isVideoCall,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CallingStatusWidget(
        calleeName: calleeName,
        isVideoCall: isVideoCall,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<CallingStatusWidget> createState() => _CallingStatusWidgetState();
}

class _CallingStatusWidgetState extends State<CallingStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _onCancel() {
    Navigator.of(context).pop();
    CallInvitationService.instance.cancelInvitation();
    widget.onCancel?.call();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by back button
      child: Material(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Call type indicator
                Icon(
                  widget.isVideoCall ? Icons.videocam : Icons.call,
                  size: 32,
                  color: widget.isVideoCall ? Colors.blue : Colors.green,
                ),
                const SizedBox(height: 16),
                
                // Status text
                Text(
                  'Calling ${widget.calleeName}...',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  widget.isVideoCall ? 'Video Call' : 'Voice Call',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Animated calling indicator
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (widget.isVideoCall ? Colors.blue : Colors.green)
                              .withOpacity(0.2),
                          border: Border.all(
                            color: widget.isVideoCall ? Colors.blue : Colors.green,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: widget.isVideoCall ? Colors.blue : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Waiting message
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.5 + (_pulseAnimation.value - 1.0) * 0.3,
                      child: const Text(
                        'Waiting for answer...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.call_end, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cancel Call',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}