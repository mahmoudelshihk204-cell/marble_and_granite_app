import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  const String baseUrl = 'http://topsoftware.ddns.net:8086/api/v1/topsoftware';

  final String username = Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final String password = Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final String schema = Platform.environment['TOPSOFTWARE_SCHEMA'] ?? '';

  final String barcode = args.isNotEmpty ? args[0] : '2311';

  if (username.isEmpty || password.isEmpty || schema.isEmpty) {
    print('Error: Login configuration is missing.');
    return;
  }

  print('Starting TopSoftware workflow test...');

  try {
    // STEP 1: LOGIN
    final Uri loginUrl = Uri.parse('$baseUrl/login');

    final loginResponse = await http
        .post(
          loginUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'username': username,
            'password': password,
            'schema': schema,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (loginResponse.statusCode != 200) {
      print('Login failed. HTTP status: ${loginResponse.statusCode}');
      return;
    }

    final dynamic decodedLogin = jsonDecode(loginResponse.body);

    if (decodedLogin is! Map<String, dynamic> ||
        decodedLogin['statusCode'] != 200) {
      print('Login failed. Invalid server response.');
      return;
    }

    final loginData = decodedLogin['data'];
    if (loginData is! Map<String, dynamic>) {
      print('Login failed. Session data is missing.');
      return;
    }

    final metaData = loginData['metaData'];
    if (metaData is! Map<String, dynamic>) {
      print('Login failed. Session metadata is missing.');
      return;
    }

    final String loginCount = metaData['loginCount']?.toString() ?? '';
    final String employeeNo = metaData['employeeNumber']?.toString() ?? '';

    if (loginCount.isEmpty || employeeNo.isEmpty) {
      print('Login failed. Session information is incomplete.');
      return;
    }

    print('Login successful.');

    // STEP 2: BARCODE SEARCH
    final Uri barcodeUrl = Uri.parse('$baseUrl/barcode').replace(
      queryParameters: {
        'schema': schema,
        'barcode': barcode,
        'loginCount': loginCount,
        'employeeNo': employeeNo,
      },
    );

    final barcodeResponse = await http
        .get(barcodeUrl, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));

    if (barcodeResponse.statusCode != 200) {
      print(
        'Barcode search failed. HTTP status: '
        '${barcodeResponse.statusCode}',
      );
      return;
    }

    final dynamic decodedBarcode = jsonDecode(barcodeResponse.body);

    if (decodedBarcode is! Map<String, dynamic> ||
        decodedBarcode['statusCode'] != 200) {
      print('Barcode search failed. Invalid server response.');
      return;
    }

    final barcodeData = decodedBarcode['data'];
    if (barcodeData is! Map<String, dynamic>) {
      print('Barcode search failed. Item data is missing.');
      return;
    }

    final item = barcodeData['metaData'];
    if (item is! Map<String, dynamic>) {
      print('Barcode search failed. Item metadata is missing.');
      return;
    }

    final warehouses = item['table'];
    final int warehouseCount = warehouses is List ? warehouses.length : 0;

    print('Barcode search successful.');
    print('Item data received: Yes');
    print('Warehouse records received: $warehouseCount');
    print('Workflow completed successfully.');
  } on TimeoutException {
    print('Request timed out.');
  } on SocketException {
    print('Connection to TopSoftware failed.');
  } on FormatException {
    print('Server returned invalid JSON.');
  } catch (_) {
    print('Workflow failed due to an unexpected error.');
  }
}
