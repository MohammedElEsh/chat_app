import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/supabase_config.dart';

/// خدمة إدارة الرسائل الصوتية في التطبيق
class VoiceService {
  static final AudioRecorder _recorder = AudioRecorder();
  static final AudioPlayer _player = AudioPlayer();

  static String? _currentRecordingPath;
  static bool _isRecording = false;
  static bool _isPlaying = false;

  /// بدء التسجيل الصوتي
  static Future<bool> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (hasPermission) {
        // إنشاء مسار مؤقت للتسجيل
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = '${appDocumentsDir.path}/voice_$timestamp.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );

        _isRecording = true;
        return true;
      } else {
        if (kDebugMode) {
          print('❌ لا توجد صلاحية للوصول للميكروفون');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في بدء التسجيل: $e');
      }
      return false;
    }
  }

  /// إيقاف التسجيل الصوتي
  static Future<File?> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _isRecording = false;

        if (path != null && File(path).existsSync()) {
          return File(path);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في إيقاف التسجيل: $e');
      }
      return null;
    }
  }

  /// إلغاء التسجيل الصوتي
  static Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _isRecording = false;

        // حذف الملف المؤقت
        if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
          await File(_currentRecordingPath!).delete();
        }

        _currentRecordingPath = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في إلغاء التسجيل: $e');
      }
    }
  }

  /// التحقق من حالة التسجيل
  static bool get isRecording => _isRecording;

  /// التحقق من حالة التشغيل
  static bool get isPlaying => _isPlaying;

  /// تشغيل ملف صوتي
  static Future<bool> playVoiceMessage(String audioUrl) async {
    try {
      if (_isPlaying) {
        await stopPlayback();
      }

      await _player.setUrl(audioUrl);
      await _player.play();

      _isPlaying = true;

      // الاستماع لانتهاء التشغيل
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في تشغيل الصوت: $e');
      }
      return false;
    }
  }

  /// إيقاف تشغيل الصوت
  static Future<void> stopPlayback() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في إيقاف تشغيل الصوت: $e');
      }
    }
  }

  /// إيقاف مؤقت للصوت
  static Future<void> pausePlayback() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في الإيقاف المؤقت للصوت: $e');
      }
    }
  }

  /// استكمال تشغيل الصوت
  static Future<void> resumePlayback() async {
    try {
      await _player.play();
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في استكمال تشغيل الصوت: $e');
      }
    }
  }

  /// الحصول على مدة الملف الصوتي
  static Future<Duration?> getAudioDuration(File audioFile) async {
    try {
      await _player.setFilePath(audioFile.path);
      return _player.duration;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في الحصول على مدة الصوت: $e');
      }
      return null;
    }
  }

  /// رفع ملف صوتي إلى Supabase
  static Future<String?> uploadVoiceToSupabase({
    required File audioFile,
    required String chatId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // قراءة بيانات الملف
      final audioBytes = Uint8List.fromList(await audioFile.readAsBytes());

      // إنشاء مسار فريد للملف الصوتي
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'voice_${user.uid}_${chatId}_$timestamp.m4a';
      final filePath = 'chats/$chatId/voices/$fileName';

      // رفع الملف الصوتي إلى Supabase
      final voiceUrl = await SupabaseConfig.uploadFile(
        bucketName: SupabaseBuckets.voiceMessages,
        filePath: filePath,
        fileName: fileName,
        fileBytes: audioBytes,
      );

      return voiceUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في رفع الملف الصوتي: $e');
      }
      return null;
    }
  }

  /// حذف ملف صوتي من Supabase
  static Future<bool> deleteVoiceFromSupabase(String voiceUrl) async {
    try {
      // استخراج مسار الملف من URL
      final uri = Uri.parse(voiceUrl);
      final pathSegments = uri.pathSegments;

      // البحث عن مسار الملف في الـ URL
      String? filePath;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'object' && i + 2 < pathSegments.length) {
          filePath = pathSegments.sublist(i + 2).join('/');
          break;
        }
      }

      if (filePath == null) {
        throw Exception('لا يمكن استخراج مسار الملف من URL');
      }

      await SupabaseConfig.deleteFile(
        bucketName: SupabaseBuckets.voiceMessages,
        filePath: filePath,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطأ في حذف الملف الصوتي: $e');
      }
      return false;
    }
  }

  /// تحرير الموارد
  static void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
