import 'package:oracledb/oracledb.dart';

import '../database/oracle_operation_queue.dart';
import '../models/legacy_balance_model.dart';

class LegacyBalanceRepository {
  // اتصال Oracle المشترك.
  final OracleConnection connection;

  // الطابور المشترك لتنظيم عمليات Oracle.
  final OracleOperationQueue queue;

  LegacyBalanceRepository({required this.connection, required this.queue});

  // جلب أرصدة صنف معين في جميع المستودعات.
  Future<List<LegacyBalanceModel>> findByItemCode(String itemCode) async {
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
    ''';

    return queue.run(() async {
      final result = await connection.execute(query, {'item_code': itemCode});

      return result.rows.map((row) {
        return LegacyBalanceModel.fromMap(row.toMap());
      }).toList();
    });
  }

  // حساب إجمالي رصيد الخامة المرتبطة بالصنف.
  Future<double?> findRawMaterialBalanceByItemCode(String itemCode) async {
    const query = '''
      SELECT
        T.ITEM_CODE,
        NVL(
          (
            SELECT SUM(NVL(B.BAL, 0))
            FROM INVMAS M
            LEFT JOIN INVMAS_BAL B
              ON B.ITEM_CODE = M.ITEM_CODE
            WHERE M.M_CLASS = T.M_CLASS
              AND M.M_TYPE = T.M_TYPE
              AND M.M_NAME = T.M_NAME
              AND M.CUST_TYPE = T.CUST_TYPE
          ),
          0
        ) AS RAW_MATERIAL_BALANCE
      FROM INVMAS T
      WHERE T.ITEM_CODE = :item_code
    ''';

    return queue.run(() async {
      final result = await connection.execute(query, {'item_code': itemCode});

      // لو الصنف غير موجود نرجع null.
      if (result.rows.isEmpty) {
        return null;
      }

      final row = result.rows.first.toMap();
      final balance = row['RAW_MATERIAL_BALANCE'];

      // تحويل قيمة Oracle إلى double لاستخدامها في JSON.
      return double.tryParse(balance.toString());
    });
  }
}
