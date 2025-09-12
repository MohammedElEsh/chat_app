import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.photoURL,
    required super.isOnline,
    required super.lastSeen,
    required super.createdAt,
  });

  // Factory from FirebaseAuth User
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      photoURL: user.photoURL ?? '',
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  // Factory from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? map['displayName'] ?? '', // Backwards compatibility
      photoURL: map['photoURL'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoURL: entity.photoURL,
      isOnline: entity.isOnline,
      lastSeen: entity.lastSeen,
      createdAt: entity.createdAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      photoURL: photoURL,
      isOnline: isOnline,
      lastSeen: lastSeen,
      createdAt: createdAt,
    );
  }

  // Helper methods for online status updates
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoURL,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Mark user as online
  UserModel markOnline() {
    return copyWith(
      isOnline: true,
      lastSeen: DateTime.now(),
    );
  }

  // Mark user as offline
  UserModel markOffline() {
    return copyWith(
      isOnline: false,
      lastSeen: DateTime.now(),
    );
  }
}
