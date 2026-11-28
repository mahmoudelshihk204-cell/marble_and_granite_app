import 'dart:io';

import 'package:backend/services/token_service.dart';

void main() {
  // قراءة الـ Token من Environment Variable.
  final token = Platform.environment['TOPSOFTWARE_TOKEN'] ?? '';

  if (token.isEmpty) {
    print('Error: TOPSOFTWARE_TOKEN is missing.');
    return;
  }

  try {
    // اختبار استخراج وفك تشفير بيانات الـ Token.
    TokenService.extractSchema(token);
    final baseUrl = TokenService.decryptBaseUrl(token);

    final uri = Uri.parse(baseUrl);

    print('========== TOKEN TEST ==========');
    print('Token validation: Successful');
    print('URL Scheme: ${uri.scheme}');
    print('Has Host: ${uri.hasAuthority}');
    print('Port: ${uri.hasPort ? uri.port : "Default"}');

    if (uri.path.endsWith('/api/v1/topsoftware')) {
      print('API Path: Valid');
    } else {
      print('API Path: Server root');
    }

    print('================================');
  } catch (_) {
    print('Token validation: Failed');
    print('Check the token configuration.');
  }
}
