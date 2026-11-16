import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:lost_and_founds_simple/model/item.dart';
import 'package:lost_and_founds_simple/model/user.dart';
import 'package:lost_and_founds_simple/services/database_helper.dart';
import 'package:lost_and_founds_simple/services/remote_sync_service.dart';

class AuthResult {
  final bool success;
  final User? user;
  final String message;

  const AuthResult({
    required this.success,
    this.user,
    required this.message,
  });
}

class AppProvider extends ChangeNotifier {
  AppProvider({
    DatabaseHelper? dbHelper,
    RemoteSyncService? remoteSyncService,
    Connectivity? connectivity,
  })  : _db = dbHelper ?? DatabaseHelper.instance,
        _remote = remoteSyncService ?? RemoteSyncService(),
        _connectivity = connectivity ?? Connectivity();

  final DatabaseHelper _db;
  final RemoteSyncService _remote;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  User? _currentUser;
  List<Item> _items = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isOnline = false;
  String _searchQuery = '';
  DateTime? _lastSyncTime;
  String? _syncStatusMessage;
  bool _initialized = false;

  User? get currentUser => _currentUser;
  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  String get searchQuery => _searchQuery;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get syncStatusMessage => _syncStatusMessage;
  bool get isRemoteConfigured => _remote.isConfigured;

  int get pendingSyncCount => _items.where((item) => !item.isSynced).length;

  List<Item> itemsByType(bool isFound) {
    final query = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      if (item.type != isFound) return false;
      if (query.isEmpty) return true;
      return item.itemName.toLowerCase().contains(query) ||
          item.itemDescription.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query) ||
          item.user.username.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _loadLocalItems();
      final results = await _connectivity.checkConnectivity();
      _isOnline = _hasConnection(results);

      _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
        final nowOnline = _hasConnection(results);
        final cameBackOnline = !_isOnline && nowOnline;
        _isOnline = nowOnline;
        notifyListeners();
        if (cameBackOnline) {
          syncWithRemote();
        }
      });

      if (_isOnline) {
        await syncWithRemote();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _loadLocalItems() async {
    _items = await _db.getItems();
  }

  // -------------------- Authentication --------------------

  Future<AuthResult> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await _db.getUserByEmail(normalizedEmail);
    if (user == null) {
      return const AuthResult(
        success: false,
        message: 'No account found with that email.',
      );
    }
    if (!user.verifyPassword(password)) {
      return const AuthResult(
        success: false,
        message: 'Incorrect password. Please try again.',
      );
    }
    _currentUser = user;
    notifyListeners();
    return AuthResult(
      success: true,
      user: user,
      message: 'Welcome back, ${user.firstName}!',
    );
  }

  Future<AuthResult> register({
    required String email,
    required String username,
    required String password,
    required String phoneNo,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existing = await _db.getUserByEmail(normalizedEmail);
    if (existing != null) {
      return AuthResult(
        success: false,
        message: '$normalizedEmail is already registered.',
      );
    }

    final newUser = User.withPlainPassword(
      email: normalizedEmail,
      username: username,
      password: password,
      phoneNo: phoneNo,
    );
    await _db.insertUser(newUser);
    _currentUser = newUser;
    notifyListeners();
    return AuthResult(
      success: true,
      user: newUser,
      message: 'Account created for ${newUser.firstName}!',
    );
  }

  void logout() {
    _currentUser = null;
    _searchQuery = '';
    notifyListeners();
  }

  // -------------------- Items CRUD --------------------

  Future<Item> addItem({
    required File pickedImage,
    required String itemName,
    required String itemDescription,
    required String location,
    required bool isFound,
    required User user,
  }) async {
    final persistedPath = await _db.persistPickedImage(pickedImage);
    final newItem = Item(
      imagePath: persistedPath,
      itemName: itemName.trim(),
      itemDescription: itemDescription.trim(),
      location: location.trim(),
      user: user,
      type: isFound,
      isSynced: false,
    );

    await _db.insertItem(newItem);
    await _loadLocalItems();
    notifyListeners();

    if (_isOnline) {
      unawaited(syncWithRemote());
    }
    return newItem;
  }

  Future<Item> updateItem({
    required Item existing,
    required String itemName,
    required String itemDescription,
    required String location,
    bool? isFound,
  }) async {
    final updated = existing.copyWith(
      itemName: itemName.trim(),
      itemDescription: itemDescription.trim(),
      location: location.trim(),
      type: isFound ?? existing.type,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await _db.updateItem(updated);
    await _loadLocalItems();
    notifyListeners();

    if (_isOnline) {
      unawaited(syncWithRemote());
    }
    return updated;
  }

  Future<void> deleteItem(Item item) async {
    await _db.softDeleteItem(item.id);
    await _loadLocalItems();
    notifyListeners();

    if (_isOnline) {
      unawaited(syncWithRemote());
    }
  }

  // -------------------- Offline-first Sync --------------------

  Future<SyncResult> syncWithRemote() async {
    if (_isSyncing) {
      return const SyncResult(success: false, message: 'Sync already in progress');
    }

    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);

    if (!_isOnline) {
      _syncStatusMessage = 'Offline mode • Saved locally';
      notifyListeners();
      return const SyncResult(
        success: false,
        message: 'You are offline. Changes are saved locally.',
      );
    }

    if (!_remote.isConfigured) {
      _lastSyncTime = DateTime.now();
      _syncStatusMessage = 'Online • Local SQLite active';
      notifyListeners();
      return const SyncResult(
        success: true,
        message: 'Online. Local SQLite is up to date.',
      );
    }

    _isSyncing = true;
    _syncStatusMessage = 'Syncing...';
    notifyListeners();

    var pushed = 0;
    var fetched = 0;

    try {
      final pending = await _db.getPendingSyncItems();
      for (final item in pending) {
        if (item.isDeleted) {
          await _remote.deleteRemoteItem(item.id);
          await _db.hardDeleteItem(item.id);
        } else {
          await _remote.pushItem(item);
          await _db.markItemSynced(item.id);
        }
        pushed++;
      }

      final remoteItems = await _remote.fetchRemoteItems();
      if (remoteItems.isNotEmpty) {
        await _db.upsertRemoteItems(remoteItems);
        fetched = remoteItems.length;
      }

      await _loadLocalItems();
      _lastSyncTime = DateTime.now();
      _syncStatusMessage = 'Synced just now';
      return SyncResult(
        success: true,
        pushedCount: pushed,
        fetchedCount: fetched,
        message: 'Synced $pushed local & $fetched remote item(s).',
      );
    } catch (e) {
      _syncStatusMessage = 'Sync failed • Will retry online';
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
