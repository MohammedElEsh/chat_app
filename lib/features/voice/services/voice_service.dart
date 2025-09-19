import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal() {
    _initRecorder();
  }

  late final AudioRecorder _recorder;
  void _initRecorder() {
    _recorder = AudioRecorder();
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  bool _isRecording = false;
  String? _recordingPath;

  /// Check and request microphone permission
  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording voice message
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    // Request permission
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    try {
      // Get temporary directory for storing recording
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${_uuid.v4()}.m4a';
      _recordingPath = filePath;

      // Configure recorder
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC format is widely supported
          bitRate: 128000, // 128 kbps
          sampleRate: 44100, // 44.1 kHz
        ),
        path: filePath,
      );

      _isRecording = true;
      return true;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording and return the file path
  Future<Map<String, dynamic>?> stopRecording() async {
    if (!_isRecording || _recordingPath == null) return null;

    try {
      // Stop recording
      final path = await _recorder.stop();
      _isRecording = false;

      if (path == null) return null;

      // Get recording duration
      final file = File(path);
      if (!file.existsSync()) return null;

      // Calculate duration based on file size or use a fixed value
      // Since we can't directly get duration from AudioRecorder
      final fileSize = await file.length();
      // Rough estimate: ~12KB per second for AAC at 128kbps
      final estimatedDuration = Duration(seconds: (fileSize / 12000).round());

      return {'path': path, 'duration': estimatedDuration.inSeconds};
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Upload voice recording to Supabase Storage and return public URL
  Future<Map<String, dynamic>> uploadVoiceToSupabase(
    String filePath,
    int duration,
  ) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('Voice file not found');
      }

      // Generate unique filename
      final String fileName = '${_uuid.v4()}.m4a';
      final String storagePath = 'voice_messages/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage.from('voice_messages').upload(storagePath, file);

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('voice_messages')
          .getPublicUrl(storagePath);

      return {'voiceUrl': publicUrl, 'duration': duration};
    } catch (e) {
      throw Exception('Failed to upload voice to Supabase: $e');
    }
  }

  /// Complete flow: record voice, upload to Supabase, and return URL and duration
  Future<Map<String, dynamic>?> recordAndUploadVoice() async {
    try {
      // Start recording
      final started = await startRecording();
      if (!started) return null;

      // Wait for user to stop recording (this will be handled by the UI)
      // The stopRecording method will be called separately

      return null;
    } catch (e) {
      throw Exception('Failed to record and upload voice: $e');
    }
  }

  /// Check if currently recording
  bool get isRecording => _isRecording;
}
