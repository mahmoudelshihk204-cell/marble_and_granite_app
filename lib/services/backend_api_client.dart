import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendApiClient {
  // عنوان الـ Backend اللي Flutter هيتصل بيه.
  final String baseUrl;

  // مسؤول عن تنفيذ طلبات HTTP.
  final http.Client _client;

  BackendApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  // البحث عن صنف باستخدام الباركود من خلال الـ Backend.
  Future<Map<String, dynamic>> searchByBarcode({
  required String username,
  required String password,
  required String token,
  required String barcode,
}) async {
  if (barcode.trim().isEmpty) {
    throw ArgumentError('Barcode cannot be empty');
  }

  final uri = Uri.parse('$baseUrl/api/items/search/barcode');

  try {
    print('========== BACKEND BARCODE REQUEST ==========');
    print('URL: $uri');
    print('ITEM CODE SENT: $barcode');

    // إرسال الطلب للـ Backend
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': username,
            'password': password,
            'token': token,
            'barcode': barcode.trim(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    print('========== BACKEND RESPONSE ==========');
    print('STATUS CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');

    // تحويل الرد إلى JSON
    final dynamic decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('Invalid backend response format');
    }

    if (response.statusCode != 200 || decodedBody['success'] != true) {
      throw Exception(
        decodedBody['message']?.toString() ?? 'Barcode search failed',
      );
    }

    final data = decodedBody['data'];

    if (data is! Map<String, dynamic>) {
      throw Exception('Item data is missing or invalid');
    }

    print('========== DATA EXTRACTED SUCCESSFULLY ==========');
    print('DATA KEYS: ${data.keys.toList()}');

    return data;
  } catch (error, stackTrace) {
    print('========== BACKEND CLIENT ERROR ==========');
    print('ERROR: $error');
    print(stackTrace);
    rethrow;
  }
}

 

  // البحث عن بيانات البلوك من خلال Dart Backend.
  Future<List<Map<String, dynamic>>> searchBlockStat({
    required String username,
    required String password,
    required String token,
    required String blockNumber,
  }) async {
    if (blockNumber.trim().isEmpty) {
      throw ArgumentError('Block number cannot be empty.');
    }

    // Flutter بيبعت POST للـ Backend.
    final uri = Uri.parse('$baseUrl/api/blocks/search/stat');

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': username,
            'password': password,
            'token': token,
            'blockNumber': blockNumber.trim(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid backend response.');
    }

    if (response.statusCode != 200 || decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'Block search failed.',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception('Invalid block data.');
    }

    // تحويل سجلات البلوك إلى List بالنوع المطلوب.
    final records = <Map<String, dynamic>>[];

    for (final row in data) {
      if (row is! Map) {
        throw Exception('Invalid block record.');
      }

      records.add(Map<String, dynamic>.from(row));
    }

    return records;
  }


  // التحقق من بيانات المستخدم عن طريق Dart Backend.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': username.trim(),
            'password': password,
            'token': token.trim(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid backend response.');
    }

    if (response.statusCode != 200 || decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'Login failed.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  // إغلاق الـ HTTP Client لما نخلص استخدامه.
  void close() {
    _client.close();
  }
}
