import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/legacy/legacy_item_model.dart';
import '../../models/legacy/legacy_balance_model.dart';
import '../../models/legacy/legacy_unit_model.dart';
import '../../models/legacy/legacy_block_model.dart';
import '../backend_api_client.dart';
import '../login_storage_service.dart';

class LegacyApiService {
  // عنوان الكمبيوتر اللي عليه Dart Server
  // الموبايل والكمبيوتر لازم يكونوا على نفس شبكة Wi-Fi
  final String baseUrl;

  LegacyApiService({String baseUrl = 'http://10.53.1.108:8080'})
    : baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  // ==========================================
  // دالة مشتركة لإرسال GET واستقبال JSON
  // ==========================================

  Future<Map<String, dynamic>> _getJson(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      // طباعة العنوان الفعلي الذي يطلبه التطبيق.
      debugPrint('API REQUEST URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      // طباعة كود الاستجابة ومحتواها لمعرفة سبب المشكلة.
      debugPrint('API STATUS CODE: ${response.statusCode}');
      debugPrint('API RESPONSE BODY: ${response.body}');

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception('Invalid server response');
      }

      final data = Map<String, dynamic>.from(decoded);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data['success'] != true) {
        throw Exception(
          'HTTP ${response.statusCode}: ${data['message'] ?? response.body}',
        );
      }

      return data;
    } catch (error) {
      debugPrint('API REQUEST ERROR: $error');
      rethrow;
    }
  }

  // البحث باستخدام Item Code.
  Future<LegacyItemModel?> getItemByCode(String itemCode) async {
    final normalizedCode = itemCode.trim();

    if (normalizedCode.isEmpty) {
      return null;
    }

    return _searchItem(normalizedCode);
  }

  // البحث باستخدام Barcode.
  // استخراج Item Code بيتم هنا مرة واحدة فقط.
  Future<LegacyItemModel?> searchByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    

    if (normalizedBarcode.length <= 4) {
      throw ArgumentError('Invalid Barcode');
    }

    final itemCode = normalizedBarcode.substring(
      3,
      normalizedBarcode.length - 1,
    );
           debugPrint('========== BARCODE SEARCH ==========');
           debugPrint('SCANNED BARCODE: $normalizedBarcode');
           debugPrint('EXTRACTED ITEM CODE: $itemCode');
           
    return _searchItem(itemCode);
  }

  // ==========================================
  // 2. البحث باستخدام الكود البديل
  // ITEM_CODE2
  // ==========================================
  Future<List<LegacyItemModel>> searchByAlternateCode(
    String alternateCode,
  ) async {
    final endpoint =
        '/api/items/search/alternate/'
        '${Uri.encodeComponent(alternateCode)}';

    final response = await _getJson(endpoint);

    final List<dynamic> items = response['data'] ?? [];

    return items.map((item) {
      return LegacyItemModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  // ==========================================
  // 3. جلب أرصدة الصنف في المستودعات
  // ==========================================
  Future<List<LegacyBalanceModel>> getBalances(String itemCode) async {
    final endpoint = '/api/items/${Uri.encodeComponent(itemCode)}/balances';

    final response = await _getJson(endpoint);

    final List<dynamic> balances = response['data'] ?? [];

    return balances.map((balance) {
      return LegacyBalanceModel.fromJson(Map<String, dynamic>.from(balance));
    }).toList();
  }

  // جلب إجمالي رصيد الخامة المرتبطة بالصنف من Oracle.
  Future<double> getRawMaterialBalance(String itemCode) async {
    final endpoint =
        '/api/items/${Uri.encodeComponent(itemCode)}/raw-material-balance';

    final response = await _getJson(endpoint);

    // قراءة إجمالي رصيد الخامة من استجابة السيرفر.
    final balance = response['rawMaterialBalance'];

    if (balance is num) {
      return balance.toDouble();
    }

    throw Exception('Invalid raw material balance');
  }

  // ==========================================
  // 4. جلب وحدات وأسعار الصنف
  // ==========================================
  Future<List<LegacyUnitModel>> getUnits(String itemCode) async {
    final endpoint = '/api/items/${Uri.encodeComponent(itemCode)}/units';

    final response = await _getJson(endpoint);

    final List<dynamic> units = response['data'] ?? [];

    return units.map((unit) {
      return LegacyUnitModel.fromJson(Map<String, dynamic>.from(unit));
    }).toList();
  }

  // ==========================================
  // 5. البحث عن بلوك باستخدام رقم البلوك ITEM_CODE2
  // ==========================================

  // البحث عن البلوك من خلال Dart Backend وتحويل النتيجة للموديل القديم.
  Future<LegacyBlockModel?> getBlockByNumber(String blockNumber) async {
    final normalizedNumber = blockNumber.trim();

    if (normalizedNumber.isEmpty) {
      return null;
    }

    // جلب السجلات من الـ Backend.
    final records = await getBlockStatRecords(normalizedNumber);

    // لو مفيش سجلات، يبقى البلوك مش موجود.
    if (records.isEmpty) {
      return null;
    }
    // العدد كما رجع مباشرة من TopSoftware.
    final quantity = _toInt(records.first['number']);
    // قراءة رقم واسم الصنف من أول سجل راجع من TopSoftware.
    final itemCode = records.first['itemCode']?.toString() ?? '';
    final itemName = records.first['itemName']?.toString() ?? '';

    debugPrint('BLOCK QUANTITY: $quantity');
    // تجميع بيانات الألواح حسب ITEM_CODE.
    final slabsMap = <String, Map<String, dynamic>>{};

    // تجميع إجمالي الرصيد حسب المستودع.
    final warehouseTotalsMap = <String, double>{};

    for (final record in records) {
      final itemCode = record['itemCode']?.toString() ?? '';
      final warehouseName = record['branchName']?.toString() ?? '';

      final amount = _toDouble(record['amount']);

      // تجميع رصيد المستودع.
      warehouseTotalsMap[warehouseName] =
          (warehouseTotalsMap[warehouseName] ?? 0) + amount;

      // إنشاء سجل الصنف أول مرة يظهر فيها.
      slabsMap.putIfAbsent(itemCode, () {
        return {
          'itemCode': itemCode,
          'itemName': record['itemName'],
          'x': record['x'],
          'y': record['y'],
          'z': record['z'],
          'unitName': record['unitName'],
          'balances': <String, double>{},
        };
      });

      // تجميع رصيد الصنف داخل المستودع.
      final balances = slabsMap[itemCode]!['balances'] as Map<String, double>;

      balances[warehouseName] = (balances[warehouseName] ?? 0) + amount;
    }

    // تحويل بيانات الألواح إلى الشكل المتوقع في الموديل.
    final slabs = slabsMap.values.map((slab) {
      final balances = slab['balances'] as Map<String, double>;

      return LegacyBlockSlabModel(
        itemCode: slab['itemCode'] as String,
        itemName: slab['itemName']?.toString(),
        x: _toNullableDouble(slab['x']),
        y: _toNullableDouble(slab['y']),
        z: _toNullableDouble(slab['z']),
        unitName: slab['unitName']?.toString(),
        balances: balances.entries.map((entry) {
          return LegacySlabBalanceModel(
            warehouseName: entry.key,
            balance: entry.value,
          );
        }).toList(),
      );
    }).toList();

    // تحويل إجماليات المستودعات.
    final warehouseTotals = warehouseTotalsMap.entries.map((entry) {
      return LegacyWarehouseTotalModel(
        warehouseName: entry.key,
        totalBalance: entry.value,
      );
    }).toList();

    // حساب إجمالي الرصيد.
    final totalBalance = warehouseTotalsMap.values.fold<double>(
      0,
      (total, balance) => total + balance,
    );

    return LegacyBlockModel(
      summary: LegacyBlockSummaryModel(
        blockNumber: normalizedNumber,
        slabCount: slabs.length,
        quantity: quantity,
        itemCode: itemCode,
        itemName: itemName,
        totalBalance: totalBalance,
      ),
      warehouseTotals: warehouseTotals,
      slabs: slabs,
    );
  }

  // تحويل القيم الرقمية بأمان.
  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // تحويل القيم الرقمية الاختيارية.
  double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // تحويل العدد إلى Integer بأمان.
  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // جلب سجلات البلوك الخام من Dart Backend.
  Future<List<Map<String, dynamic>>> getBlockStatRecords(
    String blockNumber,
  ) async {
    final credentials = await LoginStorageService().loadCredentials();

    final username = credentials['username'] ?? '';
    final password = credentials['password'] ?? '';
    final token = credentials['token'] ?? '';

    if (username.isEmpty || password.isEmpty || token.isEmpty) {
      throw Exception('Login credentials are missing.');
    }

    final client = BackendApiClient(baseUrl: baseUrl);

    try {
      return await client.searchBlockStat(
        username: username,
        password: password,
        token: token,
        blockNumber: blockNumber,
      );
    } finally {
      client.close();
    }
  }

  // البحث عن الصنف من خلال الـ Backend الجديد.
 Future<LegacyItemModel?> _searchItem(String itemCode) async {
  debugPrint('========== SEARCH ITEM START ==========');
  debugPrint('ITEM CODE: $itemCode');

  // المرحلة الأولى: استرجاع بيانات المستخدم
  debugPrint('STEP 1: Loading credentials...');

  final credentials = await LoginStorageService()
      .loadCredentials()
      .timeout(const Duration(seconds: 10));

  debugPrint('STEP 2: Credentials loaded');

  final username = credentials['username'];
  final password = credentials['password'];
  final token = credentials['token'];

  if (username == null ||
      password == null ||
      token == null ||
      username.isEmpty ||
      password.isEmpty ||
      token.isEmpty) {
    throw Exception('Login credentials not found');
  }

  debugPrint('STEP 3: Credentials validated');

  final client = BackendApiClient(baseUrl: baseUrl);

  try {
    debugPrint('STEP 4: Sending request to backend...');

    final data = await client.searchByBarcode(
      username: username,
      password: password,
      token: token,
      barcode: itemCode,
    ).timeout(const Duration(seconds: 30));

    debugPrint('STEP 5: Backend response received');
    debugPrint('RESPONSE DATA: $data');

    // تحويل الاستجابة إلى موديل الصنف
    debugPrint('STEP 6: Parsing LegacyItemModel');

    final item = LegacyItemModel.fromJson(data);

    debugPrint('STEP 7: Model parsed successfully');
    debugPrint('ITEM NAME: ${item.itemName}');
    debugPrint('ITEM CODE: ${item.itemCode}');

    return item;
  } catch (error, stackTrace) {
    debugPrint('========== SEARCH ITEM ERROR ==========');
    debugPrint('ERROR: $error');
    debugPrint('STACK TRACE: $stackTrace');
    rethrow;
  } finally {
    client.close();
    debugPrint('BACKEND CLIENT CLOSED');
  }
}
}
