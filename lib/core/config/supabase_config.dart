import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// كلاس لتهيئة وإدارة Supabase في التطبيق
class SupabaseConfig {
  /// الحصول على client الخاص بـ Supabase
  static SupabaseClient get client => Supabase.instance.client;
  
  /// تهيئة Supabase (يتم استدعاءها في main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      // ضع بيانات مشروع Supabase هنا
      url: 'https://zjsbbcbrmyipkxlrknny.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqc2JiY2JybXlpcGt4bHJrbm55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NDI3OTcsImV4cCI6MjA3MzUxODc5N30.02je_GYZV44ZIb7BGSiAHdcA8AhmNSIVX0BXGS2thHo',
    );
  }
  
  /// الحصول على URL الخاص بـ bucket معين
  static String getPublicUrl(String bucketName, String fileName) {
    return client.storage.from(bucketName).getPublicUrl(fileName);
  }
  
  /// رفع ملف إلى bucket معين
  static Future<String> uploadFile({
    required String bucketName,
    required String filePath,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final response = await client.storage.from(bucketName).uploadBinary(
      filePath,
      fileBytes,
      fileOptions: FileOptions(
        cacheControl: '3600',
        upsert: false,
      ),
    );
    
    if (response.isNotEmpty) {
      return getPublicUrl(bucketName, filePath);
    } else {
      throw Exception('فشل في رفع الملف');
    }
  }
  
  /// حذف ملف من bucket معين
  static Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    await client.storage.from(bucketName).remove([filePath]);
  }
}

/// أسماء الـ buckets المستخدمة في التطبيق
class SupabaseBuckets {
  static const String chatMedia = 'chat_media';
  static const String voiceMessages = 'voice_messages';
}