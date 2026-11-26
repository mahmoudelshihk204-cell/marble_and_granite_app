
import 'dart:io';

import 'package:backend/services/token_service.dart';

void main() {
  // قراءة الـ Token من Environment Variable
  final token = Platform.environment['TOPSOFTWARE_TOKEN'] ?? '';

  if (token.isEmpty) {
    print('Error: TOPSOFTWARE_TOKEN is missing.');
    return;
  }

  try {
    // استخراج اسم الـ Schema
    final schema = TokenService.extractSchema(token);

    // فك تشفير الـ Base URL
    final baseUrl = TokenService.decryptBaseUrl(token);

    print('========== TOKEN TEST ==========');
    print('Schema: $schema');

    // نعرض شكل الرابط فقط من غير كشف الدومين أو عنوان السيرفر.
    final uri = Uri.parse(baseUrl);

    print('URL Scheme: ${uri.scheme}');
    print('Has Host: ${uri.hasAuthority}');
    print('Port: ${uri.hasPort ? uri.port : "Default"}');
    print('Path: ${uri.path}');

    if (uri.path.endsWith('/api/v1/topsoftware')) {
      print('Result: Base URL includes API path.');
    } else {
      print('Result: Base URL is server root.');
    }

    print('================================');
  } catch (e) {
    print('Token Error: $e');
  }
}

