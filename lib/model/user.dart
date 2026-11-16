import 'dart:convert';
import 'package:crypto/crypto.dart';

class User {
  final String email;
  final String username;
  final String passwordHash;
  final String phoneNo;
  final DateTime createdAt;

  User({
    required this.email,
    required this.username,
    required this.passwordHash,
    required this.phoneNo,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a [User] from a plaintext password by hashing it with SHA-256.
  factory User.withPlainPassword({
    required String email,
    required String username,
    required String password,
    required String phoneNo,
    DateTime? createdAt,
  }) {
    return User(
      email: email.trim().toLowerCase(),
      username: username.trim(),
      passwordHash: hashPassword(password),
      phoneNo: phoneNo.trim(),
      createdAt: createdAt,
    );
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  bool verifyPassword(String plainPassword) {
    return passwordHash == hashPassword(plainPassword);
  }

  String get firstName {
    final parts = username.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : email;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'password_hash': passwordHash,
      'phone_no': phoneNo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      phoneNo: (map['phone_no'] as String?) ?? '',
      createdAt: DateTime.tryParse((map['created_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'phone_no': phoneNo,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: (json['email'] as String?) ?? 'unknown@example.com',
      username: (json['username'] as String?) ?? 'Unknown User',
      passwordHash: '',
      phoneNo: (json['phone_no'] as String?) ?? '',
    );
  }

  User copyWith({
    String? email,
    String? username,
    String? passwordHash,
    String? phoneNo,
    DateTime? createdAt,
  }) {
    return User(
      email: email ?? this.email,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      phoneNo: phoneNo ?? this.phoneNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
