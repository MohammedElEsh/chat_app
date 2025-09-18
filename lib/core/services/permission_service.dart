import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// خدمة إدارة الصلاحيات في التطبيق
class PermissionService {
  
  /// طلب صلاحية الكاميرا
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في طلب صلاحية الكاميرا: $e');
      }
      return false;
    }
  }
  
  /// طلب صلاحية الميكروفون
  static Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في طلب صلاحية الميكروفون: $e');
      }
      return false;
    }
  }
  
  /// طلب صلاحية الوصول للصور
  static Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في طلب صلاحية الصور: $e');
      }
      return false;
    }
  }
  
  /// طلب صلاحية التخزين
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في طلب صلاحية التخزين: $e');
      }
      return false;
    }
  }
  
  /// طلب جميع الصلاحيات المطلوبة للملتيميديا
  static Future<bool> requestAllMediaPermissions() async {
    try {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
        Permission.photos,
        Permission.storage,
      ].request();
      
      // التحقق من أن جميع الصلاحيات تم منحها
      bool allGranted = true;
      for (final status in statuses.values) {
        if (!status.isGranted) {
          allGranted = false;
          break;
        }
      }
      
      return allGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في طلب الصلاحيات: $e');
      }
      return false;
    }
  }
  
  /// التحقق من حالة صلاحية الكاميرا
  static Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في التحقق من صلاحية الكاميرا: $e');
      }
      return false;
    }
  }
  
  /// التحقق من حالة صلاحية الميكروفون
  static Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في التحقق من صلاحية الميكروفون: $e');
      }
      return false;
    }
  }
  
  /// التحقق من حالة صلاحية الصور
  static Future<bool> isPhotosPermissionGranted() async {
    try {
      final status = await Permission.photos.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في التحقق من صلاحية الصور: $e');
      }
      return false;
    }
  }
  
  /// فتح إعدادات التطبيق لمنح الصلاحيات يدوياً
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في فتح إعدادات التطبيق: $e');
      }
      return false;
    }
  }
  
  /// التحقق من جميع الصلاحيات المطلوبة للملتيميديا
  static Future<MediaPermissionsStatus> checkAllMediaPermissions() async {
    try {
      final cameraGranted = await isCameraPermissionGranted();
      final microphoneGranted = await isMicrophonePermissionGranted();
      final photosGranted = await isPhotosPermissionGranted();
      
      return MediaPermissionsStatus(
        camera: cameraGranted,
        microphone: microphoneGranted,
        photos: photosGranted,
        allGranted: cameraGranted && microphoneGranted && photosGranted,
      );
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في التحقق من الصلاحيات: $e');
      }
      return MediaPermissionsStatus(
        camera: false,
        microphone: false,
        photos: false,
        allGranted: false,
      );
    }
  }
}

/// كلاس لحفظ حالة الصلاحيات
class MediaPermissionsStatus {
  final bool camera;
  final bool microphone;
  final bool photos;
  final bool allGranted;
  
  const MediaPermissionsStatus({
    required this.camera,
    required this.microphone,
    required this.photos,
    required this.allGranted,
  });
  
  @override
  String toString() {
    return 'MediaPermissionsStatus(camera: $camera, microphone: $microphone, photos: $photos, allGranted: $allGranted)';
  }
}