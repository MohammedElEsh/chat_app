import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import '../../../../core/utils/constants.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String voiceUrl;
  final bool isCurrentUser;
  final Duration? duration;
  final VoidCallback? onPlayStateChanged;

  const VoiceMessagePlayer({
    super.key,
    required this.voiceUrl,
    required this.isCurrentUser,
    this.duration,
    this.onPlayStateChanged,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _player = AudioPlayer();
    
    // الاستماع لحالة التشغيل
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
                      state.processingState == ProcessingState.buffering;
        });
        
        if (state.processingState == ProcessingState.completed) {
          _resetPlayer();
        }
        
        widget.onPlayStateChanged?.call();
      }
    });

    // الاستماع لمدة الملف
    _durationSubscription = _player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // الاستماع لموقع التشغيل
    _positionSubscription = _player.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.idle ||
            _player.processingState == ProcessingState.completed) {
          await _player.setUrl(widget.voiceUrl);
        }
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ في تشغيل الملف الصوتي');
      }
    }
  }

  void _resetPlayer() {
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isCurrentUser 
        ? Colors.white 
        : AppColors.primary;
    
    final secondaryColor = widget.isCurrentUser 
        ? Colors.white.withOpacity(0.7) 
        : AppColors.primary.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _isLoading ? null : _togglePlayback,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: primaryColor,
                      size: 18,
                    ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Waveform/Progress Indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: secondaryColor,
                    thumbColor: primaryColor,
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0,
                    onChanged: (value) async {
                      if (_duration.inMilliseconds > 0) {
                        final position = Duration(
                          milliseconds: (value * _duration.inMilliseconds).round(),
                        );
                        await _player.seek(position);
                      }
                    },
                  ),
                ),
                
                // Duration Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 4),
          
          // Voice Icon
          Icon(
            Icons.mic,
            color: secondaryColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}