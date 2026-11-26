
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // عنوان الـ API الخاص بالبرنامج الأصلي
  const String baseUrl = 'http://topsoftware.ddns.net:8086/api/v1/topsoftware';

  // بيانات المستخدم من آخر Login ناجح
  const String schema = 'exp2013';
  const String loginCount = '36';
  const String employeeNo = '11';

  // الباركود اللي هنختبره
  const String barcode = '2311';

  // بناء الرابط وإضافة الـ Parameters
  final Uri url = Uri.parse('$baseUrl/barcode').replace(
    queryParameters: {
      'schema': schema,
      'barcode': barcode,
      'loginCount': loginCount,
      'employeeNo': employeeNo,
    },
  );

  print('Sending barcode request...');
  print('URL: $url');

  try {
    // إرسال GET Request للسيرفر
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 20));

    print('\n========== RESPONSE ==========');
    print('Status Code: ${response.statusCode}');

    // تحويل الرد من JSON إلى Dart Object
    final Map<String, dynamic> responseData =
        jsonDecode(response.body);

    // طباعة الـ JSON بشكل منظم
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    print('Response Body:');
    print(encoder.convert(responseData));

    print('===========================\n');

    // التأكد من نجاح الطلب
    if (response.statusCode == 200) {
      print('Barcode request completed successfully!');
    } else {
      print('Barcode request failed.');
    }
  } catch (e) {
    // لو حصل خطأ اتصال أو Timeout أو JSON Parsing
    print('Request Error: $e');
  }
}
