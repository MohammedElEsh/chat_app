import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/permission_service.dart';

/// خدمة رفع الصور المتخصصة للدردشة
class UploadService {
  final ImagePicker _picker = ImagePicker();

  /// يفتح الكاميرا → يرفع الصورة → يرجع URL
  Future<String?> pickAndUploadImageFromCamera({required String chatId}) async {
    try {
      // 1. التحقق من الصلاحيات
      final cameraPermitted = await PermissionService.requestCameraPermission();
      if (!cameraPermitted) {
        if (kDebugMode) {
          print('صلاحية الكاميرا مرفوضة');
        }
        return null;
      }

      // 2. فتح الكاميرا
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      
      // 3. رفع الصورة باستخدام ImageService الموجود
      final imageUrl = await ImageService.uploadImageToSupabase(
        imageFile: file,
        chatId: chatId,
      );

      // 4. حذف الملف المؤقت
      try {
        await file.delete();
      } catch (e) {
        if (kDebugMode) {
          print('لم يتم حذف الملف المؤقت: $e');
        }
      }

      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في رفع الصورة من الكاميرا: $e');
      }
      return null;
    }
  }

  /// يفتح المعرض → يرفع الصورة → يرجع URL
  Future<String?> pickAndUploadImageFromGallery({required String chatId}) async {
    try {
      // 1. التحقق من الصلاحيات
      final photosPermitted = await PermissionService.requestPhotosPermission();
      if (!photosPermitted) {
        if (kDebugMode) {
          print('صلاحية الصور مرفوضة');
        }
        return null;
      }

      // 2. فتح المعرض
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      
      // 3. رفع الصورة باستخدام ImageService الموجود
      final imageUrl = await ImageService.uploadImageToSupabase(
        imageFile: file,
        chatId: chatId,
      );

      // 4. حذف الملف المؤقت (إذا كان مختلف عن الأصل)
      try {
        if (file.path != pickedFile.path) {
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('لم يتم حذف الملف المؤقت: $e');
        }
      }

      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في رفع الصورة من المعرض: $e');
      }
      return null;
    }
  }

  /// رفع صورة من ملف موجود (للاستخدام المتقدم)
  Future<String?> uploadImageFile({
    required File imageFile,
    required String chatId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // رفع الصورة باستخدام ImageService الموجود
      final imageUrl = await ImageService.uploadImageToSupabase(
        imageFile: imageFile,
        chatId: chatId,
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
  Future<bool> deleteImage(String imageUrl) async {
    try {
      return await ImageService.deleteImageFromSupabase(imageUrl);
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في حذف الصورة: $e');
      }
      return false;
    }
  }

  /// إظهار dialog لاختيار مصدر الصورة (كاميرا أو معرض)
  Future<String?> showImageSourceDialog({
    required String chatId,
  }) async {
    // هذه الدالة ستتم دعوتها من UI لإظهار خيارات الكاميرا والمعرض
    // سيتم تنفيذها لاحقاً في UI layer
    throw UnimplementedError('يجب استدعاء هذه الدالة من UI layer');
  }
}