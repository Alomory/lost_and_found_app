import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const _dbName = 'lost_and_found.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        email TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        phone_no TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        image_path TEXT NOT NULL,
        item_name TEXT NOT NULL,
        item_description TEXT NOT NULL,
        location TEXT NOT NULL,
        user_email TEXT NOT NULL,
        date_time TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        type INTEGER NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_email) REFERENCES users (email)
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final demoUsers = [
      User.withPlainPassword(
        email: 'omar@gmail.com',
        username: 'Omar Alomory',
        password: 'Omar',
        phoneNo: '0182850579',
      ),
      User.withPlainPassword(
        email: 'ali@gmail.com',
        username: 'Ali Alomory',
        password: 'ali',
        phoneNo: '1078746567',
      ),
      User.withPlainPassword(
        email: 'mohammad@gmail.com',
        username: 'Mohammad Alomory',
        password: 'mohammad',
        phoneNo: '01765209878',
      ),
    ];

    for (final user in demoUsers) {
      await db.insert('users', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    final sampleImagePath = await _copyAssetImage('assets/images/nokia.jpg');
    final now = DateTime.now();

    final seedItems = [
      Item(
        id: 'seed_1',
        imagePath: sampleImagePath,
        itemName: 'Nokia Classic Phone',
        itemDescription:
            'White and blue Nokia with small screen and physical number pad.',
        location: 'FTKKI Main Hall',
        user: demoUsers[1],
        dateTime: now.subtract(const Duration(hours: 18)),
        type: false,
        isSynced: true,
      ),
      Item(
        id: 'seed_2',
        imagePath: sampleImagePath,
        itemName: 'Silver Keychain & USB',
        itemDescription:
            'Two dorm keys attached to a blue 32GB flash drive.',
        location: 'Central Library 2nd Floor',
        user: demoUsers[0],
        dateTime: now.subtract(const Duration(hours: 9)),
        type: false,
        isSynced: true,
      ),
      Item(
        id: 'seed_3',
        imagePath: sampleImagePath,
        itemName: 'Black Leather Wallet',
        itemDescription:
            'Contains student ID card and a few receipts. Left near cafe.',
        location: 'Student Center Cafeteria',
        user: demoUsers[2],
        dateTime: now.subtract(const Duration(hours: 4)),
        type: true,
        isSynced: true,
      ),
      Item(
        id: 'seed_4',
        imagePath: sampleImagePath,
        itemName: 'Wireless Earbuds Case',
        itemDescription:
            'White charging case found on the bench outside Lab 3.',
        location: 'Engineering Block B',
        user: demoUsers[0],
        dateTime: now.subtract(const Duration(hours: 2)),
        type: true,
        isSynced: true,
      ),
    ];

    for (final item in seedItems) {
      await db.insert('items', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<String> _copyAssetImage(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docsDir.path, 'item_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final targetFile = File(p.join(imagesDir.path, p.basename(assetPath)));
    if (!await targetFile.exists()) {
      await targetFile.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return targetFile.path;
  }

  /// Copies a picked image file into persistent app storage so OS cache
  /// cleanup does not delete it.
  Future<String> persistPickedImage(File sourceFile) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docsDir.path, 'item_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final ext = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final fileName = 'img_${DateTime.now().microsecondsSinceEpoch}$ext';
    final savedFile = await sourceFile.copy(p.join(imagesDir.path, fileName));
    return savedFile.path;
  }

  // -------------------- Users --------------------

  Future<List<User>> getUsers() async {
    final db = await database;
    final rows = await db.query('users');
    return rows.map(User.fromMap).toList();
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // -------------------- Items --------------------

  Future<List<Item>> getItems() async {
    final db = await database;
    final itemRows = await db.query(
      'items',
      where: 'is_deleted = 0',
      orderBy: 'date_time DESC',
    );
    final users = await getUsers();
    final userMap = {for (final u in users) u.email: u};

    return itemRows.map((row) {
      final email = row['user_email'] as String;
      final user = userMap[email] ??
          User(
            email: email,
            username: email.split('@').first,
            passwordHash: '',
            phoneNo: '',
          );
      return Item.fromMap(row, user);
    }).toList();
  }

  Future<List<Item>> getPendingSyncItems() async {
    final db = await database;
    final itemRows = await db.query(
      'items',
      where: 'is_synced = 0',
    );
    final users = await getUsers();
    final userMap = {for (final u in users) u.email: u};

    return itemRows.map((row) {
      final email = row['user_email'] as String;
      final user = userMap[email] ??
          User(
            email: email,
            username: email.split('@').first,
            passwordHash: '',
            phoneNo: '',
          );
      return Item.fromMap(row, user);
    }).toList();
  }

  Future<void> insertItem(Item item) async {
    final db = await database;
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateItem(Item item) async {
    final db = await database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> softDeleteItem(String id) async {
    final db = await database;
    await db.update(
      'items',
      {
        'is_deleted': 1,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> hardDeleteItem(String id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markItemSynced(String id) async {
    final db = await database;
    await db.update(
      'items',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> upsertRemoteItems(List<Item> remoteItems) async {
    final db = await database;
    final batch = db.batch();
    for (final item in remoteItems) {
      batch.insert(
        'users',
        item.user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      batch.insert(
        'items',
        item.copyWith(isSynced: true).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
