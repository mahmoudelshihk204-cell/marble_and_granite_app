
import '../lib/services/legacy/legacy_api_service.dart';

Future<void> main() async {
  final api = LegacyApiService();

  try {
    print('========== LEGACY API TEST ==========');

    // 1. اختبار جلب صنف باستخدام ITEM_CODE
    print('\n1. Testing getItemByCode...');
    final item = await api.getItemByCode('1500');

    if (item == null) {
      print('Item not found!');
    } else {
      print('Item Code: ${item.itemCode}');
      print('Item Name: ${item.itemName}');
      print('Alternate Code: ${item.alternateCode}');
      print('Class: ${item.className}');
    }

    // 2. اختبار البحث بالكود البديل
    print('\n2. Testing searchByAlternateCode...');
    final searchResults = await api.searchByAlternateCode('43314');

    print('Search Results Count: ${searchResults.length}');

    if (searchResults.isNotEmpty) {
      print('First Item: ${searchResults.first.itemCode}');
      print('Last Item: ${searchResults.last.itemCode}');
    }

    // 3. اختبار جلب أرصدة الصنف
    print('\n3. Testing getBalances...');
    final balances = await api.getBalances('1500');

    print('Balances Count: ${balances.length}');

    for (final balance in balances) {
      print(
        'Branch: ${balance.branchName} | '
        'Balance: ${balance.balance}',
      );
    }

    // 4. اختبار جلب وحدات وأسعار الصنف
    print('\n4. Testing getUnits...');
    final units = await api.getUnits('1500');

    print('Units Count: ${units.length}');

    for (final unit in units) {
      print(
        'Unit: ${unit.unitName} | '
        'Sale Price: ${unit.salePrice} | '
        'Master: ${unit.isMasterUnit}',
      );
    }

    print('\n========== ALL TESTS COMPLETED ==========');
  } catch (error) {
    print('\nAPI TEST FAILED!');
    print('Error: $error');
  }
}
