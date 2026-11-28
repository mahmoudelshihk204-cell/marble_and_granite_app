import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  // عنوان API الخاص بـ TopSoftware.
  const String baseUrl = 'http://topsoftware.ddns.net:8086';
  const String endpoint = '/api/v1/topsoftware/login';

  // قراءة بيانات الدخول من Environment Variables.
  final String username = Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final String password = Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final String schema = Platform.environment['TOPSOFTWARE_SCHEMA'] ?? '';

  // التأكد من وجود بيانات الاتصال.
  if (username.isEmpty || password.isEmpty || schema.isEmpty) {
    print('Error: Login configuration is missing.');
    return;
  }

  final Uri url = Uri.parse('$baseUrl$endpoint');

  final Map<String, dynamic> requestBody = {
    'username': username,
    'password': password,
    'schema': schema,
  };

  print('Starting TopSoftware login test...');

  try {
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

    print('HTTP Status: ${response.statusCode}');

    // التأكد من سلامة استجابة JSON دون عرض محتواها.
    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      print('Response format: Invalid');
      return;
    }

    if (response.statusCode == 200 && decoded['statusCode'] == 200) {
      print('TopSoftware login test: Successful');
    } else {
      print('TopSoftware login test: Failed');
    }
  } on TimeoutException {
    print('Login request timed out.');
  } on SocketException {
    print('Connection to TopSoftware failed.');
  } on FormatException {
    print('Server returned invalid JSON.');
  } catch (_) {
    print('Login test failed due to an unexpected error.');
  }
}
