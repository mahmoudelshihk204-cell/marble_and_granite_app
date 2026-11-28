import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // عنوان API الخاص بـ TopSoftware.
  const String baseUrl = 'http://topsoftware.ddns.net:8086/api/v1/topsoftware';

  // بيانات جلسة الاختبار.
  const String schema = 'exp2013';
  const String loginCount = '36';
  const String employeeNo = '11';

  // الباركود المستخدم في الاختبار.
  const String barcode = '2311';

  // بناء الرابط وإضافة Parameters.
  final Uri url = Uri.parse('$baseUrl/barcode').replace(
    queryParameters: {
      'schema': schema,
      'barcode': barcode,
      'loginCount': loginCount,
      'employeeNo': employeeNo,
    },
  );

  print('Sending barcode request...');

  try {
    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    print('========== RESPONSE ==========');
    print('Status Code: ${response.statusCode}');

    // التأكد من أن الاستجابة JSON سليمة.
    final dynamic responseData = jsonDecode(response.body);

    if (responseData is! Map) {
      print('Response format: Invalid');
      return;
    }

    print('Response format: Valid JSON');

    if (response.statusCode == 200) {
      print('Barcode request completed successfully.');
    } else {
      print('Barcode request failed.');
    }

    print('==============================');
  } on TimeoutException {
    print('Request timed out.');
  } on FormatException {
    print('Server returned invalid JSON.');
  } catch (_) {
    print('Barcode request failed due to a connection error.');
  }
}
