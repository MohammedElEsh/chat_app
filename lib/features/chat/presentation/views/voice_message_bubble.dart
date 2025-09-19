import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoiceMessageBubble extends StatefulWidget {
  final String voiceUrl;
  final int duration;
  final bool isCurrentUser;
  final Color bubbleColor;
  final Color textColor;

  const VoiceMessageBubble({
    super.key,
    required this.voiceUrl,
    required this.duration,
    required this.isCurrentUser,
    required this.bubbleColor,
    required this.textColor,
  });

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
        _audioPlayer.seek(Duration.zero);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        setState(() {
        });
      }
    });
  }

  Future<void> _loadAudio() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _audioPlayer.setUrl(widget.voiceUrl);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading audio: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer.processingState == ProcessingState.idle) {
      await _loadAudio();
    }
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause button
        IconButton(
          icon: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                  ),
                )
              : Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.textColor,
                ),
          onPressed: _isLoading ? null : _togglePlayPause,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        
        // Waveform visualization (simplified)
        Expanded(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: widget.textColor.withOpacity(0.1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                10,
                (index) => Container(
                  width: 3,
                  height: 5 + (index % 3 + 1) * 5.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    color: widget.textColor.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        // Duration text
        Text(
          _formatDuration(Duration(seconds: widget.duration)),
          style: TextStyle(
            color: widget.textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}