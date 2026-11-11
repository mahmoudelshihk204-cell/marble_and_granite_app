
import 'package:oracledb/oracledb.dart';

import '../models/legacy_item_model.dart';

class LegacyItemRepository {
  // الاتصال بقاعدة بيانات Oracle.
  final OracleConnection connection;

  LegacyItemRepository({
    required this.connection,
  });

  // البحث باستخدام ITEM_CODE وإرجاع صنف واحد أو null.
  Future<LegacyItemModel?> findByItemCode(String itemCode) async {
    const query = '''
      SELECT
        I.ITEM_CODE,
        I.ITEM_NAME,
        I.ITEM_CODE2,
        I.ITEM_NAME2,
        I.ITEM_NAME_EN,
        I.X,
        I.Y,
        I.Z,
        I.M_CLASS,
        I.M_TYPE,
        I.M_NAME,
        I.M_FINISH,
        I.M_CLR,
        I.M_FLAG,
        PC.GROUP_NAME AS CLASS_NAME,
        PT.GROUP_NAME AS TYPE_NAME,
        PN.GROUP_NAME AS MATERIAL_NAME,
        PF.GROUP_NAME AS FINISH_NAME,
        I.SYS_DATE
      FROM INVMAS I
      LEFT JOIN PLOCK_INSX PC
        ON PC.GROUP_CODE = I.M_CLASS
      LEFT JOIN PLOCK_INSX PT
        ON PT.GROUP_CODE = I.M_TYPE
      LEFT JOIN PLOCK_INSX PN
        ON PN.GROUP_CODE = I.M_NAME
      LEFT JOIN PLOCK_INSX PF
        ON PF.GROUP_CODE = I.M_FINISH
      WHERE I.ITEM_CODE = :item_code
    ''';

    // تمرير الكود كـ Bind Parameter لحماية الاستعلام.
    final result = await connection.execute(
      query,
      {'item_code': itemCode},
    );

    if (result.rows.isEmpty) {
      return null;
    }

    // تحويل نتيجة Oracle إلى Model.
    final row = result.rows.first.toMap();

    return LegacyItemModel.fromMap(row);
  }
}
