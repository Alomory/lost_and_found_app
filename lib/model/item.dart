import 'dart:io';

import 'package:lost_and_founds_simple/model/user.dart';

class Item {
  final String id;
  final String imagePath;
  final String itemName;
  final String itemDescription;
  final String location;
  final User user;
  final DateTime dateTime;
  final DateTime updatedAt;
  final bool type; // true = Found, false = Lost
  final bool isSynced;
  final bool isDeleted;

  Item({
    String? id,
    required this.imagePath,
    required this.itemName,
    required this.itemDescription,
    required this.location,
    required this.user,
    DateTime? dateTime,
    DateTime? updatedAt,
    required this.type,
    this.isSynced = false,
    this.isDeleted = false,
  })  : id = id ?? '${DateTime.now().microsecondsSinceEpoch}',
        dateTime = dateTime ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  File get imageFile => File(imagePath);
  bool get isRemoteImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  String get typeLabel => type ? 'Found' : 'Lost';

  Item copyWith({
    String? id,
    String? imagePath,
    String? itemName,
    String? itemDescription,
    String? location,
    User? user,
    DateTime? dateTime,
    DateTime? updatedAt,
    bool? type,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Item(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      location: location ?? this.location,
      user: user ?? this.user,
      dateTime: dateTime ?? this.dateTime,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'item_name': itemName,
      'item_description': itemDescription,
      'location': location,
      'user_email': user.email,
      'date_time': dateTime.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map, User user) {
    return Item(
      id: map['id'] as String,
      imagePath: map['image_path'] as String,
      itemName: map['item_name'] as String,
      itemDescription: map['item_description'] as String,
      location: map['location'] as String,
      user: user,
      dateTime: DateTime.tryParse((map['date_time'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((map['updated_at'] as String?) ?? '') ??
          DateTime.now(),
      type: (map['type'] as int) == 1,
      isSynced: (map['is_synced'] as int? ?? 0) == 1,
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'item_name': itemName,
      'item_description': itemDescription,
      'location': location,
      'user': user.toJson(),
      'date_time': dateTime.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return Item(
      id: json['id']?.toString(),
      imagePath: (json['image_path'] as String?) ?? '',
      itemName: (json['item_name'] as String?) ?? '',
      itemDescription: (json['item_description'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      user: userJson != null
          ? User.fromJson(userJson)
          : User(
              email: 'remote@example.com',
              username: 'Community Member',
              passwordHash: '',
              phoneNo: '',
            ),
      dateTime: DateTime.tryParse((json['date_time'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? '') ??
          DateTime.now(),
      type: (json['type'] as bool?) ?? false,
      isSynced: true,
    );
  }
}
