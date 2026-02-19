// lib/services/secure_storage_service.dart
//
// Enterprise-grade secure storage wrapper using flutter_secure_storage.
// - Android: EncryptedSharedPreferences backed by Android Keystore (AES-256)
// - iOS:     Keychain with first-unlock accessibility
//
// Singleton pattern — use SecureStorageService.instance throughout the app.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Custom exception for storage-layer errors.
class StorageException implements Exception {
  final String message;
  final Object? cause;

  const StorageException(this.message, {this.cause});

  @override
  String toString() => 'StorageException: $message';
}

class SecureStorageService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  // ─── Storage Instance ─────────────────────────────────────────────────────
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    // Android: use EncryptedSharedPreferences backed by Android Keystore.
    // Requires minSdkVersion 23 (Android 6.0+).
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // iOS: store in Keychain, accessible after first device unlock.
    // This balances security with background-task accessibility.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ─── Core Operations ──────────────────────────────────────────────────────

  /// Writes [value] for [key] into secure storage.
  /// Throws [StorageException] on failure.
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException('Failed to write secure value for key: $key', cause: e);
    }
  }

  /// Reads the value for [key] from secure storage.
  /// Returns `null` if the key does not exist.
  /// Throws [StorageException] on failure.
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to read secure value for key: $key', cause: e);
    }
  }

  /// Deletes the value for [key] from secure storage.
  /// Throws [StorageException] on failure.
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete secure value for key: $key', cause: e);
    }
  }

  /// Deletes ALL values from secure storage.
  /// Use with caution — typically called on logout.
  /// Throws [StorageException] on failure.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear all secure storage', cause: e);
    }
  }

  /// Returns `true` if [key] exists in secure storage.
  /// Throws [StorageException] on failure.
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw StorageException('Failed to check key existence for: $key', cause: e);
    }
  }
}
