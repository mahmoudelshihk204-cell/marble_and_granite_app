
// ignore_for_file: avoid_print

import '../lib/services/legacy/legacy_api_service.dart';

Future<void> main() async {
  // إنشاء خدمة الاتصال بالسيرفر
  final apiService = LegacyApiService();

  try {
    print('Searching for block 44324...');

    final block = await apiService.getBlockByNumber('44324');

    if (block == null) {
      print('Block not found.');
      return;
    }

    print('\n========== BLOCK SUMMARY ==========');
    print('Block Number: ${block.summary.blockNumber}');
    print('Slab Count: ${block.summary.slabCount}');
    print('Total Balance: ${block.summary.totalBalance}');

    print('\n========== WAREHOUSE TOTALS ==========');

    for (final warehouse in block.warehouseTotals) {
      print(
        '${warehouse.warehouseName}: '
        '${warehouse.totalBalance}',
      );
    }

    print('\n========== SLABS ==========');

    for (final slab in block.slabs) {
      print('\nItem Code: ${slab.itemCode}');
      print('Item Name: ${slab.itemName}');
      print('Dimensions: ${slab.x} x ${slab.y} x ${slab.z}');
      print('Unit: ${slab.unitName}');

      for (final balance in slab.balances) {
        print(
          'Warehouse: ${balance.warehouseName} | '
          'Balance: ${balance.balance}',
        );
      }
    }

    print('\nBlock test completed successfully!');
  } catch (e) {
    print('\nBlock test failed: $e');
  }
}
