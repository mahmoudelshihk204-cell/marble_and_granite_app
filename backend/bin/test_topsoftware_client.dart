import 'dart:io';
import 'package:backend/services/topsoftware_api_client.dart';

Future<void> main(List<String> args) async {
  // قراءة بيانات الاتصال من Environment Variables.
  final username = Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final password = Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final schema = Platform.environment['TOPSOFTWARE_SCHEMA'] ?? '';

  // الباركود من سطر الأوامر، والافتراضي 2311.
  final barcode = args.isNotEmpty ? args[0] : '2311';

  if (username.isEmpty || password.isEmpty || schema.isEmpty) {
    print('Error: Missing Environment Variables.');
    return;
  }

  
final client = TopSoftwareApiClient(
  // مؤقتًا هنستخدم العنوان اللي اختبرناه قبل كده.
  // بعد كده هنستبدله بالـ BaseURL المستخرج من Token.
  baseUrl: 'http://topsoftware.ddns.net:8086',

  username: username,
  password: password,
  schema: schema,
);


  try {
    print('Searching for barcode: $barcode');

    final item = await client.searchByBarcode(barcode);

    print('\n========== ITEM INFORMATION ==========');
    print('Item Code: ${item['itemCode']}');
    print('Item Name: ${item['itemName']}');
    print('Block Number: ${item['blockNumber']}');
    print('Price: ${item['price']}');
    print('Unit: ${item['unit']}');
    print('Total Over Block: ${item['totalOverBlock']}');
    print('Total Over Company: ${item['totalOverCompany']}');

    final warehouses = item['table'];

    if (warehouses is List) {
      print('\n========== WAREHOUSES ==========');

      for (final warehouse in warehouses) {
        if (warehouse is Map<String, dynamic>) {
          print('Warehouse: ${warehouse['brandName']}');
          print('Amount: ${warehouse['amount']}');
          print('Number: ${warehouse['number']}');
          print('------------------------------');
        }
      }
    }

    print('\nService test completed successfully!');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

