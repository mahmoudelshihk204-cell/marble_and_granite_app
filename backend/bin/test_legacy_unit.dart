
import 'package:backend/database/oracle_connection.dart';
import 'package:backend/repositories/legacy_unit_repository.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    final connection = await database.connect();

    final repository = LegacyUnitRepository(
      connection: connection,
    );

    // اختبار الصنف 1500.
    final units = await repository.findByItemCode('1500');

    print('');
    print('========== LEGACY UNIT TEST ==========');
    print('Total Unit Records: ${units.length}');
    print('');

    for (final unit in units) {
      print('Item Code: ${unit.itemCode}');
      print('Unit Code: ${unit.unitCode}');
      print('Unit Name: ${unit.unitName}');
      print('Unit Value: ${unit.unitValue}');

      print('Cost Price: ${unit.costPrice}');
      print('Wholesale Price: ${unit.wholesalePrice}');
      print('Sale Price: ${unit.salePrice}');
      print('Average Cost: ${unit.averageCost}');

      print('Master Unit: ${unit.isMasterUnit}');
      print('Balance Unit Code: ${unit.balanceUnitCode}');
      print('Secondary Unit: ${unit.secondaryUnitName}');
      print('Conversion Value: ${unit.conversionValue}');

      print('--------------------------------------');
    }

    print('======================================');
  } catch (error) {
    print('Legacy unit test failed: $error');
  } finally {
    await database.close();
  }
}
