// lib/services/auth_token_manager.dart
//
// Clean-architecture facade for all authentication token operations.
// All sensitive data (token, user profile) is stored exclusively via
// SecureStorageService — never in SharedPreferences or plain text.
//
// Usage:
//   await AuthTokenManager.instance.saveToken(token);
//   final token = await AuthTokenManager.instance.getToken();
//   final exists = await AuthTokenManager.instance.hasToken();
//   await AuthTokenManager.instance.clearAll(); // on logout

import 'dart:convert';
import 'secure_storage_service.dart';

/// Typed storage key constants — no hardcoded strings at call sites.
class _AuthKeys {
  _AuthKeys._();

  static const String accessToken = 'auth_access_token';
  static const String userData    = 'auth_user_data';
  static const String username    = 'auth_username';
  static const String email       = 'auth_email';
  static const String phone       = 'auth_phone';
}

class AuthTokenManager {
  // ─── Singleton ────────────────────────────────────────────────────────────
  AuthTokenManager._internal();
  static final AuthTokenManager instance = AuthTokenManager._internal();

  final SecureStorageService _storage = SecureStorageService.instance;

  // ─── Token Operations ─────────────────────────────────────────────────────

  /// Saves the [accessToken] securely.
  /// Throws [StorageException] on failure.
  Future<void> saveToken(String accessToken) async {
    await _storage.write(key: _AuthKeys.accessToken, value: accessToken);
  }

  /// Returns the stored access token, or `null` if not found.
  /// Throws [StorageException] on failure.
  Future<String?> getToken() async {
    return _storage.read(key: _AuthKeys.accessToken);
  }

  /// Returns `true` if an access token exists in secure storage.
  /// Use this for auto-login checks at app startup.
  Future<bool> hasToken() async {
    return _storage.containsKey(key: _AuthKeys.accessToken);
  }

  /// Deletes only the access token (e.g. on token expiry).
  Future<void> deleteToken() async {
    await _storage.delete(key: _AuthKeys.accessToken);
  }

  // ─── User Data Operations ─────────────────────────────────────────────────

  /// Saves the full [userData] map as a JSON string securely.
  /// Also saves individual fields for quick access.
  /// Throws [StorageException] on failure.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Save the full user object as JSON
    await _storage.write(
      key: _AuthKeys.userData,
      value: jsonEncode(userData),
    );

    // Save individual fields for convenient access
    final username = userData['username']?.toString() ??
        userData['name']?.toString() ??
        userData['full_name']?.toString() ??
        'User';

    final email = userData['email']?.toString() ?? '';

    final phone = userData['phone']?.toString() ??
        userData['mobile']?.toString() ??
        userData['contact']?.toString() ??
        '';

    await Future.wait([
      _storage.write(key: _AuthKeys.username, value: username),
      _storage.write(key: _AuthKeys.email,    value: email),
      _storage.write(key: _AuthKeys.phone,    value: phone),
    ]);
  }

  /// Returns the stored user data as a [Map], or `null` if not found.
  /// Falls back to individual fields if the full JSON is unavailable.
  /// Throws [StorageException] on failure.
  Future<Map<String, dynamic>?> getUserData() async {
    final userJson = await _storage.read(key: _AuthKeys.userData);

    if (userJson != null && userJson.isNotEmpty) {
      try {
        return jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        // JSON parse failed — fall through to individual fields
      }
    }

    // Fallback: reconstruct from individual fields
    final username = await _storage.read(key: _AuthKeys.username);
    final email    = await _storage.read(key: _AuthKeys.email);
    final phone    = await _storage.read(key: _AuthKeys.phone);

    if (username == null && email == null && phone == null) {
      return null;
    }

    return {
      'username': username ?? 'User',
      'email':    email    ?? '',
      'phone':    phone    ?? '',
    };
  }

  /// Returns the stored username, or `null` if not found.
  Future<String?> getUsername() async {
    return _storage.read(key: _AuthKeys.username);
  }

  /// Returns the stored email, or `null` if not found.
  Future<String?> getEmail() async {
    return _storage.read(key: _AuthKeys.email);
  }

  /// Returns the stored phone, or `null` if not found.
  Future<String?> getPhone() async {
    return _storage.read(key: _AuthKeys.phone);
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Clears ALL authentication data from secure storage.
  /// Call this on logout to ensure no sensitive data remains on device.
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _AuthKeys.accessToken),
      _storage.delete(key: _AuthKeys.userData),
      _storage.delete(key: _AuthKeys.username),
      _storage.delete(key: _AuthKeys.email),
      _storage.delete(key: _AuthKeys.phone),
    ]);
  }
}
