import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class TopSoftwareApiClient {
  // العنوان بيتحدد وقت إنشاء الـ Client بدل ما يكون ثابت هنا.
  final String _baseUrl;

  final String username;
  final String password;
  final String schema;

  final http.Client _client;

  TopSoftwareApiClient({
    required String baseUrl,
    required this.username,
    required this.password,
    required this.schema,
    http.Client? client,
  }) : _baseUrl = _normalizeBaseUrl(baseUrl),
       _client = client ?? http.Client();

  // توحيد عنوان السيرفر ومنع تكرار مسار API.
  static String _normalizeBaseUrl(String value) {
    var url = value.trim();

    // إضافة البروتوكول لو مش موجود.
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // حذف / من نهاية العنوان.
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    const apiPath = '/api/v1/topsoftware';

    // منع إضافة مسار API مرتين.
    if (url.endsWith(apiPath)) {
      return url;
    }

    return '$url$apiPath';
  }

  // تسجيل الدخول والحصول على بيانات الجلسة.
  Future<TopSoftwareSession> login() async {
    final uri = Uri.parse('$_baseUrl/login');

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Connection': 'close',
          },
          body: jsonEncode({
            'username': username,
            'password': password,
            'schema': schema,
          }),
        )
        .timeout(const Duration(seconds: 30));

    final json = _decodeResponse(response);

    if (response.statusCode != 200 || json['statusCode'] != 200) {
      throw TopSoftwareApiException(
        'TopSoftware login failed. Status: ${response.statusCode}',
      );
    }

    final data = json['data'];

    if (data is! Map) {
      throw TopSoftwareApiException('Login data is missing.');
    }

    final metaData = data['metaData'];

    if (metaData is! Map) {
      throw TopSoftwareApiException('Login metadata is missing.');
    }

    final loginCount = metaData['loginCount']?.toString() ?? '';
    final employeeNo = metaData['employeeNumber']?.toString() ?? '';

    if (loginCount.isEmpty || employeeNo.isEmpty) {
      throw TopSoftwareApiException('Session information is incomplete.');
    }

    return TopSoftwareSession(loginCount: loginCount, employeeNo: employeeNo);
  }

  // البحث بالباركود بعد تسجيل الدخول.
  Future<Map<String, dynamic>> searchByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) {
      throw ArgumentError('Barcode cannot be empty.');
    }

    final session = await login();

    final uri = Uri.parse('$_baseUrl/barcode').replace(
      queryParameters: {
        'schema': schema,
        'barcode': barcode.trim(),
        'loginCount': session.loginCount,
        'employeeNo': session.employeeNo,
      },
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));

    final json = _decodeResponse(response);

    if (response.statusCode != 200 || json['statusCode'] != 200) {
      throw TopSoftwareApiException(
        'Barcode search failed. Status: ${response.statusCode}',
      );
    }

    final data = json['data'];

    if (data is! Map) {
      throw TopSoftwareApiException('Barcode data is missing.');
    }

    final item = data['metaData'];

    if (item is! Map) {
      throw TopSoftwareApiException('Item metadata is missing.');
    }

    // الاحتفاظ بكل الحقول الراجعة من API.
    return Map<String, dynamic>.from(item);
  }

  // البحث عن كل سجلات البلوك من TopSoftware API.
  Future<List<Map<String, dynamic>>> searchBlockStat(String blockNumber) async {
    if (blockNumber.trim().isEmpty) {
      throw ArgumentError('Block number cannot be empty.');
    }

    // تسجيل الدخول للحصول على بيانات الجلسة.
    final session = await login();

    final uri = Uri.parse('$_baseUrl/blockstat').replace(
      queryParameters: {
        'schema': schema,
        'blocknumber': blockNumber.trim(),
        'loginCount': session.loginCount,
        'employeeNo': session.employeeNo,
      },
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));

    final json = _decodeResponse(response);

    if (response.statusCode != 200 || json['statusCode'] != 200) {
      throw TopSoftwareApiException(
        'Block stat request failed. Status: ${response.statusCode}',
      );
    }

    final data = json['data'];

    if (data is! Map) {
      throw TopSoftwareApiException('Block stat data is missing.');
    }

    final metadata = data['metaData'];

    if (metadata is! List) {
      throw TopSoftwareApiException(
        'Block stat metadata is missing or invalid.',
      );
    }

    // إنشاء قائمة بالنوع الصحيح، مع التأكد من سلامة كل سجل.
    final records = <Map<String, dynamic>>[];

    for (final row in metadata) {
      if (row is! Map) {
        throw TopSoftwareApiException('Block stat contains an invalid record.');
      }

      records.add(Map<String, dynamic>.from(row));
    }

    return records;
  }

  // تحويل استجابة السيرفر إلى JSON والتأكد من سلامتها.
  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw TopSoftwareApiException('Server returned invalid JSON.');
    }

    if (decoded is! Map) {
      throw TopSoftwareApiException('Unexpected server response format.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  // إغلاق اتصال HTTP.
  void close() {
    _client.close();
  }
}

class TopSoftwareSession {
  final String loginCount;
  final String employeeNo;

  const TopSoftwareSession({
    required this.loginCount,
    required this.employeeNo,
  });
}

class TopSoftwareApiException implements Exception {
  final String message;

  const TopSoftwareApiException(this.message);

  @override
  String toString() => message;
}
