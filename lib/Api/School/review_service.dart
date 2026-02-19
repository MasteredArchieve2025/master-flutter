// lib/Api/School/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_token_manager.dart';
import '../baseurl.dart';

class ReviewService {
  static String get baseUrl => '${BaseUrl.baseUrl}/api/reviews';
  
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final AuthTokenManager _authManager = AuthTokenManager.instance;

  // Get auth token from AuthTokenManager
  Future<String?> _getToken() async {
    return await _authManager.getToken();
  }

  // Get user ID from AuthTokenManager
  Future<int?> _getUserId() async {
    final userData = await _authManager.getUserData();
    if (userData != null && userData['id'] != null) {
      return userData['id'] as int?;
    }
    return null;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authManager.hasToken();
  }

  // Fetch reviews for an entity (school or tuition)
  Future<List<Map<String, dynamic>>> getEntityReviews({
    required String entityType, // 'school' or 'tuition'
    required int entityId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$entityType/$entityId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Handle the response format from your API
        if (data['reviews'] != null && data['reviews'] is List) {
          final List<dynamic> reviews = data['reviews'];
          return reviews.map((review) => Map<String, dynamic>.from(review)).toList();
        } else if (data['data'] != null && data['data'] is List) {
          final List<dynamic> reviews = data['data'];
          return reviews.map((review) => Map<String, dynamic>.from(review)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  // Fetch average rating for an entity
  Future<Map<String, dynamic>> getAverageRating({
    required String entityType,
    required int entityId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$entityType/$entityId/average'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        return {'averageRating': 0.0, 'totalReviews': 0};
      }
    } catch (e) {
      return {'averageRating': 0.0, 'totalReviews': 0};
    }
  }

  // Add a new review
  Future<Map<String, dynamic>> addReview({
    required String entityType,
    required int entityId,
    required int rating,
    required String review,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'entityType': entityType,
          'entityId': entityId,
          'rating': rating,
          'review': review,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        // Handle duplicate review error
        throw ReviewException(
          responseData['message'] ?? 'You have already reviewed this entity',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401) {
        throw ReviewException(
          'Please login to post a review',
          statusCode: response.statusCode,
        );
      } else {
        throw ReviewException(
          responseData['message'] ?? 'Failed to add review',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ReviewException) rethrow;
      throw ReviewException('Error adding review: $e');
    }
  }

  // Format review data from API to match app's review format
  Map<String, dynamic> formatReview(Map<String, dynamic> apiReview) {
    return {
      'id': apiReview['id'] ?? 0,
      'name': apiReview['username'] ?? apiReview['userName'] ?? apiReview['user']?['name'] ?? 'Anonymous',
      'rating': apiReview['rating'] ?? 0,
      'comment': apiReview['review'] ?? apiReview['comment'] ?? '',
      'userId': apiReview['userId'] ?? 0,
      'createdAt': apiReview['createdAt'] ?? '',
    };
  }
}

// Custom exception class for review errors
class ReviewException implements Exception {
  final String message;
  final int? statusCode;

  ReviewException(this.message, {this.statusCode});

  @override
  String toString() => message;
}