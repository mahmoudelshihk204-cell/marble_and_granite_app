
import 'package:backend/database/oracle_connection.dart';
import 'package:backend/repositories/legacy_balance_repository.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    final connection = await database.connect();

    final repository = LegacyBalanceRepository(
      connection: connection,
    );

    // اختبار الصنف رقم 1500.
    final balances = await repository.findByItemCode('1500');

    print('');
    print('========== LEGACY BALANCE TEST ==========');
    print('Total Warehouse Records: ${balances.length}');
    print('');

    for (final balance in balances) {
      print('Item Code: ${balance.itemCode}');
      print('Branch Code: ${balance.branchCode}');
      print('Branch Name: ${balance.branchName}');
      print('BAL: ${balance.balance}');
      print('NBAL (raw): ${balance.negativeBalance}');
      print('RAIS: ${balance.rais}');
      print('RE_DEM: ${balance.reDem}');
      print('-----------------------------------------');
    }

    print('==========================================');
  } catch (error) {
    print('Legacy balance test failed: $error');
  } finally {
    await database.close();
  }
}
