import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lost_and_founds_simple/model/item.dart';

class SyncResult {
  final bool success;
  final int pushedCount;
  final int fetchedCount;
  final String message;

  const SyncResult({
    required this.success,
    this.pushedCount = 0,
    this.fetchedCount = 0,
    required this.message,
  });
}

/// Handles fetching and pushing items to a remote REST/Firebase endpoint
/// whenever network connectivity is available.
class RemoteSyncService {
  RemoteSyncService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL'),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Future<List<Item>> fetchRemoteItems() async {
    if (!isConfigured) return [];
    final uri = Uri.parse('${baseUrl.trim()}/items');
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Remote fetch failed (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Item.fromJson)
          .toList();
    }
    return [];
  }

  Future<void> pushItem(Item item) async {
    if (!isConfigured) return;
    final uri = Uri.parse('${baseUrl.trim()}/items/${item.id}');
    final response = await _client
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(item.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Remote push failed (${response.statusCode})');
    }
  }

  Future<void> deleteRemoteItem(String id) async {
    if (!isConfigured) return;
    final uri = Uri.parse('${baseUrl.trim()}/items/$id');
    final response =
        await _client.delete(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 ||
        (response.statusCode >= 300 && response.statusCode != 404)) {
      throw Exception('Remote delete failed (${response.statusCode})');
    }
  }
}
