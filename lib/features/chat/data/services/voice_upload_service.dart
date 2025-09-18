import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/voice_service.dart';
import '../../../../core/services/permission_service.dart';

/// خدمة رفع الرسائل الصوتية المتخصصة للدردشة
class VoiceUploadService {
  
  /// بدء التسجيل الصوتي
  static Future<bool> startRecording() async {
    try {
      // التحقق من الصلاحيات
      final microphonePermitted = await PermissionService.requestMicrophonePermission();
      if (!microphonePermitted) {
        if (kDebugMode) {
          print('صلاحية الميكروفون مرفوضة');
        }
        return false;
      }

      // بدء التسجيل باستخدام VoiceService
      return await VoiceService.startRecording();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في بدء التسجيل: $e');
      }
      return false;
    }
  }

  /// إيقاف التسجيل ورفع الملف الصوتي
  static Future<String?> stopRecordingAndUpload({required String chatId}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // إيقاف التسجيل والحصول على الملف
      final audioFile = await VoiceService.stopRecording();
      if (audioFile == null) {
        if (kDebugMode) {
          print('فشل في الحصول على ملف التسجيل');
        }
        return null;
      }

      // رفع الملف الصوتي باستخدام VoiceService
      final voiceUrl = await VoiceService.uploadVoiceToSupabase(
        audioFile: audioFile,
        chatId: chatId,
      );

      // حذف الملف المؤقت
      try {
        await audioFile.delete();
      } catch (e) {
        if (kDebugMode) {
          print('لم يتم حذف الملف المؤقت: $e');
        }
      }

      return voiceUrl;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في إيقاف التسجيل والرفع: $e');
      }
      return null;
    }
  }

  /// إلغاء التسجيل الحالي
  static Future<void> cancelRecording() async {
    try {
      await VoiceService.cancelRecording();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في إلغاء التسجيل: $e');
      }
    }
  }

  /// التحقق من حالة التسجيل
  static bool get isRecording => VoiceService.isRecording;

  /// تشغيل رسالة صوتية
  static Future<bool> playVoiceMessage(String voiceUrl) async {
    try {
      return await VoiceService.playVoiceMessage(voiceUrl);
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تشغيل الرسالة الصوتية: $e');
      }
      return false;
    }
  }

  /// إيقاف تشغيل الصوت
  static Future<void> stopPlayback() async {
    try {
      await VoiceService.stopPlayback();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في إيقاف تشغيل الصوت: $e');
      }
    }
  }

  /// إيقاف مؤقت للصوت
  static Future<void> pausePlayback() async {
    try {
      await VoiceService.pausePlayback();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في الإيقاف المؤقت للصوت: $e');
      }
    }
  }

  /// استكمال تشغيل الصوت
  static Future<void> resumePlayback() async {
    try {
      await VoiceService.resumePlayback();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في استكمال تشغيل الصوت: $e');
      }
    }
  }

  /// التحقق من حالة التشغيل
  static bool get isPlaying => VoiceService.isPlaying;

  /// حذف رسالة صوتية من Supabase
  static Future<bool> deleteVoiceMessage(String voiceUrl) async {
    try {
      return await VoiceService.deleteVoiceFromSupabase(voiceUrl);
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في حذف الرسالة الصوتية: $e');
      }
      return false;
    }
  }

  /// الحصول على مدة ملف صوتي (للاستخدام المتقدم)
  static Future<Duration?> getAudioDuration(File audioFile) async {
    try {
      return await VoiceService.getAudioDuration(audioFile);
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في الحصول على مدة الصوت: $e');
      }
      return null;
    }
  }
}