import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String photoURL;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.photoURL,
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
  });

  // Backwards compatibility getter
  String get displayName => name;

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoURL,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoURL, isOnline, lastSeen, createdAt];
}
