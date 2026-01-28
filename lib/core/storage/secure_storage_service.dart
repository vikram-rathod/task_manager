// lib/core/storage/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_service.dart';

class SecureStorageService implements StorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService(this._secureStorage);

  @override
  Future<void> write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      print(' Storage: Saved $key');
    } catch (e) {
      print(' Storage Error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      print(' Storage Error: $e');
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      print(' Storage: Deleted $key');
    } catch (e) {
      print(' Storage Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      print(' Storage: Cleared all data');
    } catch (e) {
      print(' Storage Error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e) {
      print(' Storage Error: $e');
      return false;
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      print(' Storage Error: $e');
      return {};
    }
  }
}