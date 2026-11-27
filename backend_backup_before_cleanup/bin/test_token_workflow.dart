import 'dart:io';

import 'package:backend/services/token_service.dart';
import 'package:backend/services/topsoftware_api_client.dart';

Future<void> main(List<String> args) async {
  // بيانات المستخدم والـ Token.
  final username = Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final password = Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final token = Platform.environment['TOPSOFTWARE_TOKEN'] ?? '';

  final barcode = args.isNotEmpty ? args[0] : '2311';

  if (username.isEmpty || password.isEmpty || token.isEmpty) {
    print('Error: Username, Password or Token is missing.');
    return;
  }

  try {
    // استخراج اسم الـ Schema من أول وآخر حرف في Token.
    final schema = TokenService.extractSchema(token);

    // فك تشفير الجزء الأوسط واستخراج BaseURL.
    final baseUrl = TokenService.decryptBaseUrl(token);

    print('========== TOKEN INFORMATION ==========');
    print('Schema: $schema');
    print('BaseURL: $baseUrl');

    // إنشاء الاتصال باستخدام البيانات المستخرجة.
    final client = TopSoftwareApiClient(
      baseUrl: baseUrl,
      username: username,
      password: password,
      schema: schema,
    );

    try {
      print('\nSearching for barcode: $barcode');

      // تسجيل الدخول يتم تلقائيًا قبل البحث.
      final item = await client.searchByBarcode(barcode);

      print('\n========== LOGIN & SEARCH SUCCESS ==========');
      print('Item Code: ${item['itemCode']}');
      print('Item Name: ${item['itemName']}');
      print('Block Number: ${item['blockNumber']}');
      print('Price: ${item['price']}');

      print('\nToken workflow completed successfully!');
    } finally {
      client.close();
    }
  } catch (e) {
    print('\nWorkflow Error: $e');
  }
}
