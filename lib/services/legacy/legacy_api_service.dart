import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/legacy/legacy_item_model.dart';
import '../../models/legacy/legacy_balance_model.dart';
import '../../models/legacy/legacy_unit_model.dart';
import '../../models/legacy/legacy_block_model.dart';

class LegacyApiService {
  // عنوان الكمبيوتر اللي عليه Dart Server
  // الموبايل والكمبيوتر لازم يكونوا على نفس شبكة Wi-Fi
  final String baseUrl;

  LegacyApiService({String baseUrl = 'http://10.135.72.108:8080'})
    : baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  // ==========================================
  // دالة مشتركة لإرسال GET واستقبال JSON
  // ==========================================
  Future<Map<String, dynamic>> _getJson(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid server response');
    }

    final data = Map<String, dynamic>.from(decoded);

    // لو السيرفر رجّع خطأ، نعرض الرسالة
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] != true) {
      throw Exception(data['message'] ?? 'Server request failed');
    }

    return data;
  }

  // ==========================================
  // 1. جلب بيانات صنف باستخدام ITEM_CODE
  // ==========================================
  Future<LegacyItemModel?> getItemByCode(String itemCode) async {
    final endpoint = '/api/items/${Uri.encodeComponent(itemCode)}';

    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    // لو الصنف مش موجود نرجع null
    if (response.statusCode == 404) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid server response');
    }

    final data = Map<String, dynamic>.from(decoded);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to get item');
    }

    // تحويل JSON إلى LegacyItemModel
    return LegacyItemModel.fromJson(Map<String, dynamic>.from(data['data']));
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
  Future<LegacyBlockModel?> getBlockByNumber(String blockNumber) async {
    // لو المستخدم مدخلش رقم نرجع null
    if (blockNumber.trim().isEmpty) {
      return null;
    }

    final endpoint = '/api/blocks/${Uri.encodeComponent(blockNumber.trim())}';

    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    // لو البلوك مش موجود
    if (response.statusCode == 404) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid server response');
    }

    final data = Map<String, dynamic>.from(decoded);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to get block');
    }

    // تحويل بيانات البلوك إلى موديل Flutter
    return LegacyBlockModel.fromJson(Map<String, dynamic>.from(data['data']));
  }
}
