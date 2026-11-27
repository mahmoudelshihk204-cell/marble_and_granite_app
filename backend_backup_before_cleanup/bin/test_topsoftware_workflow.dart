
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  // عنوان الـ API الأصلي
  const String baseUrl =
      'http://topsoftware.ddns.net:8086/api/v1/topsoftware';

  // قراءة بيانات الدخول من Environment Variables
  final String username =
      Platform.environment['TOPSOFTWARE_USERNAME'] ?? '';
  final String password =
      Platform.environment['TOPSOFTWARE_PASSWORD'] ?? '';
  final String schema =
      Platform.environment['TOPSOFTWARE_SCHEMA'] ?? '';

  // الباركود: نقدر نبعته وقت تشغيل البرنامج
  // ولو مبعتناش حاجة هيستخدم 2311 للاختبار
  final String barcode = args.isNotEmpty ? args[0] : '2311';

  // التأكد إن بيانات الدخول موجودة
  if (username.isEmpty || password.isEmpty || schema.isEmpty) {
    print('Error: Login credentials are missing!');
    print('Check your Environment Variables.');
    return;
  }

  try {
    // ==========================================
    // STEP 1: LOGIN
    // ==========================================

    print('\n========== STEP 1: LOGIN ==========');

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

    print('Login HTTP Status: ${loginResponse.statusCode}');

    // تحويل رد السيرفر من JSON إلى Map
    final dynamic decodedLogin = jsonDecode(loginResponse.body);

    if (decodedLogin is! Map<String, dynamic>) {
      print('Error: Unexpected login response format.');
      return;
    }

    // لازم يكون طلب تسجيل الدخول ناجح
    if (loginResponse.statusCode != 200 ||
        decodedLogin['statusCode'] != 200) {
      print('Login failed!');
      print(loginResponse.body);
      return;
    }

    // استخراج بيانات الجلسة من رد تسجيل الدخول
    final loginData = decodedLogin['data'];
    if (loginData is! Map<String, dynamic>) {
      print('Error: Login data is missing.');
      return;
    }

    final metaData = loginData['metaData'];
    if (metaData is! Map<String, dynamic>) {
      print('Error: Login metadata is missing.');
      return;
    }

    final String loginCount =
        metaData['loginCount']?.toString() ?? '';
    final String employeeNo =
        metaData['employeeNumber']?.toString() ?? '';

    if (loginCount.isEmpty || employeeNo.isEmpty) {
      print('Error: Session information is incomplete.');
      return;
    }

    print('Login successful!');
    print('Employee Number: $employeeNo');
    print('Login Count: $loginCount');

    // ==========================================
    // STEP 2: BARCODE SEARCH
    // ==========================================

    print('\n========== STEP 2: BARCODE SEARCH ==========');
    print('Searching for barcode: $barcode');

    // تجهيز رابط البحث مع بيانات الجلسة الجديدة
    final Uri barcodeUrl = Uri.parse('$baseUrl/barcode').replace(
      queryParameters: {
        'schema': schema,
        'barcode': barcode,
        'loginCount': loginCount,
        'employeeNo': employeeNo,
      },
    );

    final barcodeResponse = await http
        .get(
          barcodeUrl,
          headers: {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 30));

    print('Barcode HTTP Status: ${barcodeResponse.statusCode}');

    // تحويل رد البحث إلى JSON
    final dynamic decodedBarcode = jsonDecode(barcodeResponse.body);

    if (decodedBarcode is! Map<String, dynamic>) {
      print('Error: Unexpected barcode response format.');
      return;
    }

    // التأكد من نجاح البحث
    if (barcodeResponse.statusCode != 200 ||
        decodedBarcode['statusCode'] != 200) {
      print('Barcode search failed!');
      print(barcodeResponse.body);
      return;
    }

    // استخراج بيانات الصنف
    final barcodeData = decodedBarcode['data'];
    if (barcodeData is! Map<String, dynamic>) {
      print('Error: Barcode data is missing.');
      return;
    }

    final item = barcodeData['metaData'];
    if (item is! Map<String, dynamic>) {
      print('Error: Item metadata is missing.');
      return;
    }

    // عرض أهم بيانات الصنف
    print('\n========== ITEM INFORMATION ==========');
    print('Item Code: ${item['itemCode']}');
    print('Item Name: ${item['itemName']}');
    print('Block Number: ${item['blockNumber']}');
    print('Price: ${item['price']}');
    print('Unit: ${item['unit']}');
    print('Total Over Block: ${item['totalOverBlock']}');
    print('Total Over Company: ${item['totalOverCompany']}');

    // عرض أرصدة المخازن
    final warehouses = item['table'];

    if (warehouses is List) {
      print('\n========== WAREHOUSE INFORMATION ==========');

      for (final warehouse in warehouses) {
        if (warehouse is Map<String, dynamic>) {
          print('Warehouse: ${warehouse['brandName']}');
          print('Amount: ${warehouse['amount']}');
          print('Number: ${warehouse['number']}');
          print('-----------------------------------');
        }
      }
    }

    print('\nWorkflow completed successfully!');

  } on FormatException catch (e) {
    print('JSON Parsing Error: $e');
  } on SocketException catch (e) {
    print('Connection Error: $e');
  } catch (e) {
    print('Unexpected Error: $e');
  }
}
