// lib/pages/auth/auth_api.dart
import 'package:dio/dio.dart';

const String baseUrl = "https://master-backend-18ik.onrender.com";

class AuthApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Map<String, dynamic>> loginApi(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/auth/login', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> signupApi(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/auth/signup', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> forgotPasswordApi(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/auth/forgot-password', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 
             e.response?.data['error'] ?? 
             'Something went wrong';
    }
    return 'Network Error';
  }
}