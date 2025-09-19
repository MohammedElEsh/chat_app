import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../chat/data/datasources/firebase_chat_datasource.dart';
import '../../chat/domain/entities/message_entity.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  final FirebaseChatDataSource _chatDataSource = FirebaseChatDataSourceImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from camera: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  /// Show image source selection dialog and pick image
  Future<File?> pickImage() async {
    // For simplicity, we'll use gallery by default
    // You can modify this to show a dialog for camera/gallery selection
    return await pickImageFromGallery();
  }

  /// Upload image to Supabase Storage and return public URL
  Future<String> uploadImageToSupabase(File imageFile) async {
    try {
      // Generate unique filename
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = 'images/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage
          .from('chat_media')
          .upload(filePath, imageFile);

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('chat_media')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Supabase: $e');
    }
  }

  /// Complete flow: pick image, upload to Supabase, and send message to Firestore
  Future<String?> pickAndUploadImage() async {
    try {
      // Pick image
      final File? imageFile = await pickImage();
      if (imageFile == null) {
        return null; // User cancelled
      }

      // Upload to Supabase
      final String publicUrl = await uploadImageToSupabase(imageFile);

      // Send message to Firestore
      await _chatDataSource.sendMessage(
        content: 'Image', // Content can be a placeholder like 'Image'
        type: MessageType.image,
        imageUrl: publicUrl,
      );

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to pick and upload image: $e');
    }
  }
}
