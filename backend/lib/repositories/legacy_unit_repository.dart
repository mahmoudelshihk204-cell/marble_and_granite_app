
import 'package:oracledb/oracledb.dart';

import '../models/legacy_unit_model.dart';

class LegacyUnitRepository {
  // الاتصال بقاعدة بيانات Oracle.
  final OracleConnection connection;

  LegacyUnitRepository({
    required this.connection,
  });

  // جلب كل وحدات وأسعار الصنف.
  Future<List<LegacyUnitModel>> findByItemCode(
    String itemCode,
  ) async {
    const query = '''
      SELECT
        UE.ITEM_CODE,
        UE.UNIT_CODE,
        U.UNIT_NAME AS UNIT_NAME,
        U.UNIT_VAL AS UNIT_VAL,

        UE.COST_PRICE,
        UE.WHOL_PRICE,
        UE.SALE_PRICE,
        UE.AVR_COST,

        UE.UNIT_MASTER,
        UE.BAL_UNIT_CODE,
       U2.UNIT_NAME AS UNIT_NAME2,
        UE.CONV_VAL

      FROM UNITES UE

      LEFT JOIN UNIT U
        ON U.UNIT_CODE = UE.UNIT_CODE

      LEFT JOIN UNIT U2
        ON U2.UNIT_CODE = UE.BAL_UNIT_CODE

      WHERE UE.ITEM_CODE = :item_code

      ORDER BY UE.UNIT_CODE
    ''';

    // تمرير كود الصنف بشكل آمن.
    final result = await connection.execute(
      query,
      {'item_code': itemCode},
    );

    // تحويل كل سجل إلى LegacyUnitModel.
    return result.rows.map((row) {
      return LegacyUnitModel.fromMap(row.toMap());
    }).toList();
  }
}
