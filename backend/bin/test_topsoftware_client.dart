import 'dart:async';
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
    print('Error: Missing connection configuration.');
    return;
  }

  final client = TopSoftwareApiClient(
    baseUrl: 'http://topsoftware.ddns.net:8086',
    username: username,
    password: password,
    schema: schema,
  );

  try {
    print('Starting barcode search test...');

    final item = await client.searchByBarcode(barcode);

    print('========== SEARCH RESULT ==========');
    print('Barcode search: Successful');
    print('Item data received: ${item.isNotEmpty}');

    final warehouses = item['table'];

    if (warehouses is List) {
      print('Warehouse records received: ${warehouses.length}');
    } else {
      print('Warehouse records: Not available');
    }

    print('Service test completed successfully.');
    print('===================================');
  } on TimeoutException {
    print('Request timed out.');
  } catch (_) {
    print('Barcode search test failed.');
    print('Check connection configuration and server availability.');
  } finally {
    client.close();
  }
}
