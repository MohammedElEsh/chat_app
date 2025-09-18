import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/supabase_config.dart';

/// خدمة إدارة الصور في التطبيق
class ImageService {
  static final ImagePicker _picker = ImagePicker();
  
  /// التقاط صورة من الكاميرا
  static Future<File?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في التقاط الصورة: $e');
      }
      return null;
    }
  }
  
  /// اختيار صورة من المعرض
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في اختيار الصورة: $e');
      }
      return null;
    }
  }
  
  /// ضغط الصورة لتوفير مساحة التخزين والنقل
  static Future<Uint8List?> compressImage(File imageFile) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 800,
        minHeight: 600,
        quality: 70,
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في ضغط الصورة: $e');
      }
      return null;
    }
  }
  
  /// رفع صورة إلى Supabase
  static Future<String?> uploadImageToSupabase({
    required File imageFile,
    required String chatId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }
      
      // ضغط الصورة أولاً
      final compressedBytes = await compressImage(imageFile);
      if (compressedBytes == null) {
        throw Exception('فشل في ضغط الصورة');
      }
      
      // إنشاء مسار فريد للصورة
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'image_${user.uid}_${chatId}_$timestamp.jpg';
      final filePath = 'chats/$chatId/images/$fileName';
      
      // رفع الصورة إلى Supabase
      final imageUrl = await SupabaseConfig.uploadFile(
        bucketName: SupabaseBuckets.chatMedia,
        filePath: filePath,
        fileName: fileName,
        fileBytes: compressedBytes,
      );
      
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في رفع الصورة: $e');
      }
      return null;
    }
  }
  
  /// حذف صورة من Supabase
  static Future<bool> deleteImageFromSupabase(String imageUrl) async {
    try {
      // استخراج مسار الملف من URL
      final uri = Uri.parse(imageUrl);
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
        bucketName: SupabaseBuckets.chatMedia,
        filePath: filePath,
      );
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في حذف الصورة: $e');
      }
      return false;
    }
  }
}