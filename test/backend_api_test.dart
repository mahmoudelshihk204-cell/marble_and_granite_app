
import 'dart:io';

import 'package:marble_and_granite/services/backend_api_client.dart';

Future<void> main() async {
  // إدخال بيانات تسجيل الدخول وقت تشغيل الاختبار.
  stdout.write('Username: ');
  final username = stdin.readLineSync() ?? '';

  stdout.write('Password: ');
  final password = stdin.readLineSync() ?? '';

  stdout.write('Token: ');
  final token = stdin.readLineSync() ?? '';

  // إنشاء Client للتواصل مع الـ Backend.
  final api = BackendApiClient(
    baseUrl: 'http://localhost:8080',
  );

  try {
    print('\nSearching for barcode 2311...\n');

    // تنفيذ البحث وإنتظار النتيجة.
    final item = await api.searchByBarcode(
      username: username,
      password: password,
      token: token,
      barcode: '2311',
    );

    // طباعة البيانات اللي رجعت من السيرفر.
    print('========== ITEM FOUND ==========');
    print('Item Code: ${item['itemCode']}');
    print('Item Name: ${item['itemName']}');
    print('Block Number: ${item['blockNumber']}');
    print('Price: ${item['price']}');
    print('Unit: ${item['unit']}');
    print('==============================');
  } catch (error) {
    print('\nSearch failed: $error');
  } finally {
    // إغلاق الاتصال بعد انتهاء الاختبار.
    api.close();
  }
}
