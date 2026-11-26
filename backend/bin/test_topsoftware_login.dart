
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  // بيانات الاتصال بالـ API الأصلي
  const String baseUrl = 'http://topsoftware.ddns.net:8086';
  const String endpoint = '/api/v1/topsoftware/login';

  // بنقرأ بيانات تسجيل الدخول من Environment Variables
  // علشان ما نحطش بيانات الدخول داخل الكود
  final String username = Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final String password = Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final String schema = Platform.environment['TOPSOFTWARE_SCHEMA'] ?? '';

  // التأكد إن البيانات موجودة
  if (username.isEmpty || password.isEmpty || schema.isEmpty) {
    print('Error: Login credentials are missing!');
    print('Set TOPSOFTWARE_USERNAME, TOPSOFTWARE_PASSWORD and TOPSOFTWARE_SCHEMA');
    return;
  }

  // تجهيز عنوان الـ Request
  final Uri url = Uri.parse('$baseUrl$endpoint');

  // تجهيز البيانات اللي هتتبعت في الـ Body
  final Map<String, dynamic> requestBody = {
    'username': username,
    'password': password,
    'schema': schema,
  };

  print('Sending login request...');
  print('URL: $url');

  try {
    // إرسال POST Request واستقبال الرد
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 30));

    print('\n========== RESPONSE ==========');
    print('Status Code: ${response.statusCode}');
    print('Response Body:');
    print(response.body);
    print('===========================');
  } catch (e) {
    // التعامل مع مشاكل الاتصال أو انتهاء الوقت
    print('Request failed: $e');
  }
}
