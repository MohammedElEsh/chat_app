import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/config/zego_config.dart';

class IncomingCallDialog extends StatefulWidget {
  final String callerName;
  final String callerId;
  final bool isVideoCall;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallDialog({
    super.key,
    required this.callerName,
    required this.callerId,
    required this.isVideoCall,
    required this.onAccept,
    required this.onDecline,
  });

  static void show({
    required BuildContext context,
    required String callerName,
    required String callerId,
    required bool isVideoCall,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingCallDialog(
        callerName: callerName,
        callerId: callerId,
        isVideoCall: isVideoCall,
        onAccept: onAccept,
        onDecline: onDecline,
      ),
    );
  }

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  Timer? _timeoutTimer;
  int _remainingSeconds = ZegoConfig.invitationTimeoutSeconds;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimeoutCountdown();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
    _scaleController.forward();
  }

  void _startTimeoutCountdown() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _onTimeout();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _onTimeout() {
    if (mounted) {
      Navigator.of(context).pop();
      widget.onDecline();
    }
  }

  void _onAccept() {
    _timeoutTimer?.cancel();
    Navigator.of(context).pop();
    widget.onAccept();
  }

  void _onDecline() {
    _timeoutTimer?.cancel();
    Navigator.of(context).pop();
    widget.onDecline();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing by back button
      child: Material(
        color: Colors.black.withOpacity(0.8),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
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
                      const SizedBox(height: 8),
                      
                      // Incoming call text
                      Text(
                        'Incoming ${widget.isVideoCall ? 'Video' : 'Voice'} Call',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Caller avatar and name
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                border: Border.all(
                                  color: widget.isVideoCall ? Colors.blue : Colors.green,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: widget.callerId.isNotEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[600],
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[600],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Caller name
                      Text(
                        widget.callerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Calling text with animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.5 + (_pulseAnimation.value - 1.0) * 0.5,
                            child: const Text(
                              'Calling...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Timeout countdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_remainingSeconds}s',
                          style: TextStyle(
                            fontSize: 14,
                            color: _remainingSeconds <= 10 ? Colors.red : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Decline button
                          GestureDetector(
                            onTap: _onDecline,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          
                          // Accept button
                          GestureDetector(
                            onTap: _onAccept,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.isVideoCall ? Icons.videocam : Icons.call,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Action labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'Decline',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Accept',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
