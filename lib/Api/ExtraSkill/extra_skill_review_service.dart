// lib/Api/ExtraSkill/extra_skill_review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_token_manager.dart';
import '../baseurl.dart';

class ExtraSkillReviewService {
  static String get baseUrl => '${BaseUrl.baseUrl}/api/extra-skill-reviews';
  
  static final ExtraSkillReviewService _instance = ExtraSkillReviewService._internal();
  factory ExtraSkillReviewService() => _instance;
  ExtraSkillReviewService._internal();

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

  // Fetch reviews for an institution
  Future<List<Map<String, dynamic>>> getInstitutionReviews({
    required int institutionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$institutionId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((review) => Map<String, dynamic>.from(review)).toList();
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  // Fetch average rating for an institution
  Future<Map<String, dynamic>> getAverageRating({
    required int institutionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$institutionId/average'),
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
    required int institutionId,
    required int rating,
    required String review,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw ReviewException('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'institutionId': institutionId,
          'rating': rating,
          'review': review,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        throw ReviewException(
          responseData['message'] ?? 'You have already reviewed this institution',
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
      'name': 'User ${apiReview['userId'] ?? ''}', // Using userId since username not available
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