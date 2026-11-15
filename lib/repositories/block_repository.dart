import 'package:marble_and_granite/models/legacy/legacy_item_model.dart';

import '../models/legacy/legacy_block_model.dart';
import '../services/legacy/legacy_api_service.dart';

// Repository مسؤول عن توفير البيانات للـ Cubit
// ويفصل منطق التطبيق عن التعامل المباشر مع API.
class BlockRepository {
  final LegacyApiService apiService;

  BlockRepository(this.apiService);

  // البحث عن البلوك باستخدام رقمه.
  Future<LegacyBlockModel?> getBlockByNumber(
    String blockNumber,
  ) async {
    return await apiService.getBlockByNumber(blockNumber);
  }

  // البحث عن الصنف باستخدام الباركود.
  Future<LegacyItemModel?> getItemByBarcode(String barcode) async {
    return await apiService.searchByBarcode(barcode);
  }

  // البحث عن الصنف باستخدام Item Code.
  Future<LegacyItemModel?> getItemByCode(String itemCode) async {
    return await apiService.getItemByCode(itemCode);
  }
}
