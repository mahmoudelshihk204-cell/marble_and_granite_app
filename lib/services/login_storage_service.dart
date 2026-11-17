import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginStorageService {
  // إنشاء كائن مسؤول عن التعامل مع التخزين الآمن على الجهاز.
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // أسماء المفاتيح اللي هنخزن تحتها البيانات.
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _tokenKey = 'saved_token';

  // حفظ بيانات تسجيل الدخول بشكل آمن.
  Future<void> saveCredentials({
    required String username,
    required String password,
    required String token,
  }) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
    await _storage.write(key: _tokenKey, value: token);
  }

  // استرجاع بيانات تسجيل الدخول المحفوظة.
  Future<Map<String, String?>> loadCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    final token = await _storage.read(key: _tokenKey);

    return {'username': username, 'password': password, 'token': token};
  }

  // مسح بيانات تسجيل الدخول المحفوظة من الجهاز.
  Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _tokenKey);
  }
}
