
import 'package:oracledb/oracledb.dart';

import '../models/legacy_balance_model.dart';

class LegacyBalanceRepository {
  // الاتصال بقاعدة بيانات Oracle.
  final OracleConnection connection;

  LegacyBalanceRepository({
    required this.connection,
  });

  // البحث عن كل أرصدة صنف معين في المستودعات.
  Future<List<LegacyBalanceModel>> findByItemCode(
    String itemCode,
  ) async {
    const query = '''
      SELECT
        B.ITEM_CODE,
        B.BRAN_CODE,
        BR.GROUP_NAME AS BRANCH_NAME,
        B.BAL,
        B.NBAL,
        B.RAIS,
        B.RE_DEM,
        B.SYS_DATE
      FROM INVMAS_BAL B
      LEFT JOIN BRANCH BR
        ON BR.GROUP_CODE = B.BRAN_CODE
      WHERE B.ITEM_CODE = :item_code
      ORDER BY B.BRAN_CODE
    ''';

    // تمرير كود الصنف كـ Bind Parameter.
    final result = await connection.execute(
      query,
      {'item_code': itemCode},
    );

    // تحويل كل صف إلى LegacyBalanceModel.
    return result.rows.map((row) {
      return LegacyBalanceModel.fromMap(row.toMap());
    }).toList();
  }
}
