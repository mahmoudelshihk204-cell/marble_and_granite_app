
import 'package:oracledb/oracledb.dart';

class LegacyBlockRepository {
  final OracleConnection connection;

  LegacyBlockRepository({required this.connection});

  Future<Map<String, dynamic>?> findByBlockNumber(
    String blockNumber,
  ) async {
    // جلب ألواح البلوك من جدول الأصناف الرئيسية
    const itemsQuery = '''
      SELECT
        I.ITEM_CODE,
        I.ITEM_CODE2,
        I.ITEM_NAME,
        I.X,
        I.Y,
        I.Z,
        (
          SELECT MAX(U.UNIT_NAME)
          FROM UNITES UE
          LEFT JOIN UNIT U ON U.UNIT_CODE = UE.UNIT_CODE
          WHERE UE.ITEM_CODE = I.ITEM_CODE
            AND UE.UNIT_MASTER = 1
        ) AS UNIT_NAME
      FROM INVMAS I
      WHERE I.ITEM_CODE2 = :block_number
      ORDER BY I.ITEM_CODE
    ''';

    final itemsResult = await connection.execute(
      itemsQuery,
      {'block_number': blockNumber},
    );

    if (itemsResult.rows.isEmpty) return null;

    final slabs = itemsResult.rows.map((row) => row.toMap()).toList();

    // تجهيز أكواد الألواح لاستخدامها في استعلام الأرصدة
    final itemCodes = slabs
        .map((slab) => slab['ITEM_CODE'].toString())
        .toList();

    final bindValues = <String, dynamic>{};
    final placeholders = <String>[];

    for (var i = 0; i < itemCodes.length; i++) {
      final key = 'item_$i';
      placeholders.add(':$key');
      bindValues[key] = itemCodes[i];
    }

    // جلب رصيد كل لوح في كل مستودع
    final balancesQuery = '''
      SELECT
        B.ITEM_CODE,
        B.BRAN_CODE,
        BR.GROUP_NAME AS WAREHOUSE_NAME,
        B.BAL
      FROM INVMAS_BAL B
      LEFT JOIN BRANCH BR ON BR.GROUP_CODE = B.BRAN_CODE
      WHERE B.ITEM_CODE IN (${placeholders.join(', ')})
      ORDER BY B.ITEM_CODE, B.BRAN_CODE
    ''';

    final balancesResult = await connection.execute(
      balancesQuery,
      bindValues,
    );

    final balancesByItem = <String, List<Map<String, dynamic>>>{};
    final warehouseTotals = <String, Map<String, dynamic>>{};

    for (final row in balancesResult.rows) {
      final balance = row.toMap();
      final itemCode = balance['ITEM_CODE'].toString();
      final branchCode = balance['BRAN_CODE'].toString();
      final warehouseName = balance['WAREHOUSE_NAME']?.toString();

      final rawBalance = balance['BAL'];
      final amount = rawBalance is num
          ? rawBalance
          : num.tryParse(rawBalance?.toString() ?? '') ?? 0;

      // الاحتفاظ برصيد كل لوح حتى لو كان صفر أو بالسالب
      balancesByItem.putIfAbsent(itemCode, () => []);
      balancesByItem[itemCode]!.add({
        'warehouseName': warehouseName,
        'balance': amount,
      });

      // تجميع إجمالي رصيد البلوك حسب المستودع
      warehouseTotals.putIfAbsent(branchCode, () {
        return {
          'warehouseName': warehouseName,
          'totalBalance': 0,
        };
      });

      warehouseTotals[branchCode]!['totalBalance'] =
          (warehouseTotals[branchCode]!['totalBalance'] as num) + amount;
    }

    // تجهيز تفاصيل كل لوح
    final slabData = slabs.map((slab) {
      final itemCode = slab['ITEM_CODE'].toString();

      return {
        'itemCode': itemCode,
        'itemName': slab['ITEM_NAME'],
        'x': slab['X'],
        'y': slab['Y'],
        'z': slab['Z'],
        'unitName': slab['UNIT_NAME'],
        'balances': balancesByItem[itemCode] ?? [],
      };
    }).toList();

    // حساب إجمالي رصيد البلوك في كل المستودعات
    final totalBalance = warehouseTotals.values.fold<num>(
      0,
      (total, warehouse) =>
          total + (warehouse['totalBalance'] as num),
    );

    return {
      'summary': {
        'blockNumber': blockNumber,
        'slabCount': slabs.length,
        'totalBalance': totalBalance,
      },
      'warehouseTotals': warehouseTotals.values.toList(),
      'slabs': slabData,
    };
  }
}
