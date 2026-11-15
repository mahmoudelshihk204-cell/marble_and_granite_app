
import 'package:marble_and_granite/models/legacy/legacy_item_model.dart';

import '../models/legacy/legacy_block_model.dart';
import '../models/legacy/legacy_balance_model.dart';
import '../services/legacy/legacy_api_service.dart';

// Repository مسؤول عن توفير البيانات للـ Cubit والصفحات.
class BlockRepository {
  final LegacyApiService apiService;

  BlockRepository(this.apiService);

  // البحث عن بلوك باستخدام رقمه.
  Future<LegacyBlockModel?> getBlockByNumber(
    String blockNumber,
  ) async {
    return await apiService.getBlockByNumber(blockNumber);
  }

  // البحث عن صنف باستخدام الباركود.
  Future<LegacyItemModel?> getItemByBarcode(String barcode) async {
    return await apiService.searchByBarcode(barcode);
  }

  // البحث عن صنف باستخدام Item Code.
  Future<LegacyItemModel?> getItemByCode(String itemCode) async {
    return await apiService.getItemByCode(itemCode);
  }

  // جلب أرصدة الصنف في جميع المستودعات.
  Future<List<LegacyBalanceModel>> getItemBalances(
    String itemCode,
  ) async {
    return await apiService.getBalances(itemCode);
  }
}
