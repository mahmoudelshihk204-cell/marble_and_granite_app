import 'dart:io';

import 'package:backend/services/token_service.dart';
import 'package:backend/services/topsoftware_api_client.dart';

Future<void> main(List<String> args) async {
  // قراءة بيانات الاتصال من Environment Variables.
  final username = Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final password = Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final token = Platform.environment['TOPSOFTWARE_TOKEN'] ?? '';

  final barcode = args.isNotEmpty ? args[0] : '2311';

  if (username.isEmpty || password.isEmpty || token.isEmpty) {
    print('Error: Required connection configuration is missing.');
    return;
  }

  TopSoftwareApiClient? client;

  try {
    // استخراج بيانات الاتصال من الـ Token.
    final schema = TokenService.extractSchema(token);
    final baseUrl = TokenService.decryptBaseUrl(token);

    // إنشاء الاتصال باستخدام البيانات المستخرجة.
    client = TopSoftwareApiClient(
      baseUrl: baseUrl,
      username: username,
      password: password,
      schema: schema,
    );

    print('========== TOKEN WORKFLOW TEST ==========');
    print('Token validation: Successful');
    print('Client initialization: Successful');

    // تسجيل الدخول يتم تلقائيًا قبل البحث.
    final item = await client.searchByBarcode(barcode);

    print('Login and barcode search: Successful');
    print('Item data received: ${item.isNotEmpty}');
    print('Workflow completed successfully.');
    print('=========================================');
  } catch (_) {
    print('Token workflow failed.');
    print('Check the connection configuration and server availability.');
  } finally {
    client?.close();
  }
}
