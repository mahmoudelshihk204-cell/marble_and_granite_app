
import 'package:backend/database/oracle_connection.dart';
import 'package:backend/repositories/legacy_block_repository.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    final connection = await database.connect();

    final repository = LegacyBlockRepository(
      connection: connection,
    );

    // اختبار البلوك 44324
    final block = await repository.findByBlockNumber('44324');

    print('');
    print('========== LEGACY BLOCK TEST ==========');

    if (block == null) {
      print('Block not found');
      return;
    }

    final summary = block['summary'] as Map<String, dynamic>;

    print('');
    print('BLOCK SUMMARY');
    print('Block Number: ${summary['blockNumber']}');
    print('Slab Count: ${summary['slabCount']}');
    print('Total Balance: ${summary['totalBalance']}');

    print('');
    print('WAREHOUSE TOTALS');

    for (final warehouse in block['warehouseTotals'] as List) {
      print('Warehouse: ${warehouse['warehouseName']}');
      print('Total Balance: ${warehouse['totalBalance']}');
      print('---------------------------------------');
    }

    print('');
    print('SLAB DETAILS');

    for (final slab in block['slabs'] as List) {
      print('Item Code: ${slab['itemCode']}');
      print('Dimensions: ${slab['x']} x ${slab['y']}');
      print('Unit: ${slab['unitName']}');

      for (final balance in slab['balances'] as List) {
        print('Warehouse: ${balance['warehouseName']}');
        print('Balance: ${balance['balance']}');
      }

      print('---------------------------------------');
    }

    print('========== TEST FINISHED ==========');
  } catch (error, stackTrace) {
    print('Legacy block test failed: $error');
    print(stackTrace);
  } finally {
    await database.close();
  }
}
