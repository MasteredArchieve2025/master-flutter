// lib/services/user_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../Api/baseurl.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final Map<int, String> _userCache = {};

  Future<String> getUserName(int userId) async {
    // Check cache first
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/api/users/$userId'),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        String name = userData['name'] ?? 
                     userData['username'] ?? 
                     userData['fullName'] ?? 
                     'User $userId';
        
        // Cache the result
        _userCache[userId] = name;
        return name;
      }
    } catch (e) {
      debugPrint('Error fetching user $userId: $e');
    }
    
    return 'User $userId';
  }

  // Method to fetch multiple users at once (more efficient)
  Future<Map<int, String>> getMultipleUserNames(List<int> userIds) async {
    final Map<int, String> results = {};
    final List<int> usersToFetch = [];

    // Check cache first
    for (var userId in userIds) {
      if (_userCache.containsKey(userId)) {
        results[userId] = _userCache[userId]!;
      } else {
        usersToFetch.add(userId);
      }
    }

    // Fetch uncached users
    if (usersToFetch.isNotEmpty) {
      try {
        // You might need a batch endpoint on your backend
        // For now, fetch one by one
        for (var userId in usersToFetch) {
          final name = await getUserName(userId);
          results[userId] = name;
        }
      } catch (e) {
        debugPrint('Error fetching multiple users: $e');
      }
    }

    return results;
  }

  // Clear cache if needed
  void clearCache() {
    _userCache.clear();
  }
}