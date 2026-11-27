import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/postgres_connection.dart';
import 'package:postgres/postgres.dart';

// الأعمدة اللي هنقارنها بين Oracle و PostgreSQL
const List<String> columns = [
  'ITEM_CODE',
  'M_CLASS',
  'CLASS_NAME',
  'M_TYPE',
  'TYPE_NAME',
  'M_NAME',
  'MATERIAL_NAME',
  'M_FINISH',
  'FINISH_NAME',
];

// مقارنة القيم مع مراعاة إن NULL يساوي NULL
bool sameValue(Object? first, Object? second) {
  if (first == null || second == null) {
    return first == second;
  }

  return first.toString() == second.toString();
}

Future<void> main() async {
  final oracleDatabase = OracleDatabase();
  final postgresDatabase = PostgresDatabase();

  Connection? postgresConnection;

  try {
    // الاتصال بقاعدتي البيانات
    final oracleConnection = await oracleDatabase.connect();
    postgresConnection = await postgresDatabase.connect();

    print('\nStarting INVMAS JOIN verification...');

    // استعلام Oracle: نفس طريقة الربط المستخدمة في التطبيق الأصلي
    const oracleQuery = '''
      SELECT
        I.ITEM_CODE,
        I.M_CLASS,
        PC.GROUP_NAME AS CLASS_NAME,
        I.M_TYPE,
        PT.GROUP_NAME AS TYPE_NAME,
        I.M_NAME,
        PN.GROUP_NAME AS MATERIAL_NAME,
        I.M_FINISH,
        PF.GROUP_NAME AS FINISH_NAME
      FROM EXP2013.INVMAS I
      LEFT JOIN EXP2013.PLOCK_INSX PC
        ON PC.GROUP_CODE = I.M_CLASS
      LEFT JOIN EXP2013.PLOCK_INSX PT
        ON PT.GROUP_CODE = I.M_TYPE
      LEFT JOIN EXP2013.PLOCK_INSX PN
        ON PN.GROUP_CODE = I.M_NAME
      LEFT JOIN EXP2013.PLOCK_INSX PF
        ON PF.GROUP_CODE = I.M_FINISH
      ORDER BY I.ITEM_CODE
    ''';

    final oracleResult = await oracleConnection.execute(oracleQuery);

    print('Oracle JOIN records: ${oracleResult.rows.length}');

    // استعلام PostgreSQL بنفس الـ JOIN تماماً
    const postgresQuery = '''
      SELECT
        i.item_code,
        i.m_class,
        pc.group_name AS class_name,
        i.m_type,
        pt.group_name AS type_name,
        i.m_name,
        pn.group_name AS material_name,
        i.m_finish,
        pf.group_name AS finish_name
      FROM public.invmas i
      LEFT JOIN public.plock_insx pc
        ON pc.group_code = i.m_class
      LEFT JOIN public.plock_insx pt
        ON pt.group_code = i.m_type
      LEFT JOIN public.plock_insx pn
        ON pn.group_code = i.m_name
      LEFT JOIN public.plock_insx pf
        ON pf.group_code = i.m_finish
      ORDER BY i.item_code
    ''';

    final postgresResult = await postgresConnection.execute(postgresQuery);

    print('PostgreSQL JOIN records: ${postgresResult.length}');

    // نخزن نتائج PostgreSQL باستخدام ITEM_CODE كمفتاح
    final postgresData = <String, List<dynamic>>{};

    for (final row in postgresResult) {
      final itemCode = row[0].toString();

      if (postgresData.containsKey(itemCode)) {
        throw Exception('Duplicate ITEM_CODE after JOIN: $itemCode');
      }

      postgresData[itemCode] = List<dynamic>.generate(
        columns.length,
        (index) => row[index],
      );
    }

    int comparedRecords = 0;
    int missingRecords = 0;
    int extraRecords = 0;
    int totalDifferences = 0;

    final columnErrors = <String, int>{};
    final printedErrors = <String>[];

    // نقارن كل سجل من Oracle بنظيره في PostgreSQL
    for (final oracleRow in oracleResult.rows) {
      final oracleData = oracleRow.toMap();
      final itemCode = oracleData['ITEM_CODE'].toString();

      final postgresRow = postgresData[itemCode];

      if (postgresRow == null) {
        missingRecords++;

        if (printedErrors.length < 20) {
          printedErrors.add('Missing ITEM_CODE in PostgreSQL: $itemCode');
        }

        continue;
      }

      comparedRecords++;

      for (int i = 0; i < columns.length; i++) {
        final column = columns[i];
        final oracleValue = oracleData[column];
        final postgresValue = postgresRow[i];

        if (!sameValue(oracleValue, postgresValue)) {
          totalDifferences++;

          columnErrors[column] = (columnErrors[column] ?? 0) + 1;

          if (printedErrors.length < 20) {
            printedErrors.add(
              'ITEM_CODE: $itemCode | '
              'COLUMN: $column | '
              'Oracle: $oracleValue | '
              'PostgreSQL: $postgresValue',
            );
          }
        }
      }
    }

    // نتحقق كمان إن PostgreSQL مفيهوش أصناف زيادة
    final oracleCodes = oracleResult.rows
        .map((row) => row.toMap()['ITEM_CODE'].toString())
        .toSet();

    for (final itemCode in postgresData.keys) {
      if (!oracleCodes.contains(itemCode)) {
        extraRecords++;

        if (printedErrors.length < 20) {
          printedErrors.add('Extra ITEM_CODE in PostgreSQL: $itemCode');
        }
      }
    }

    // طباعة النتيجة النهائية
    print('\n========== JOIN VERIFICATION RESULT ==========');
    print('Oracle JOIN records      : ${oracleResult.rows.length}');
    print('PostgreSQL JOIN records  : ${postgresResult.length}');
    print('Compared records         : $comparedRecords');
    print('Missing records          : $missingRecords');
    print('Extra records            : $extraRecords');
    print('Different values         : $totalDifferences');
    print('================================================');

    if (columnErrors.isNotEmpty) {
      print('\nDifferences by column:');

      columnErrors.forEach((column, count) {
        print('$column: $count differences');
      });
    }

    if (printedErrors.isNotEmpty) {
      print('\nFirst differences found:');

      for (final error in printedErrors) {
        print(error);
      }
    }

    if (missingRecords == 0 &&
        extraRecords == 0 &&
        totalDifferences == 0 &&
        oracleResult.rows.length == postgresResult.length) {
      print('\nSUCCESS: All JOIN results match!');
    } else {
      print('\nVERIFICATION FAILED: JOIN differences found.');
    }
  } catch (error) {
    print('\nJOIN verification failed: $error');
    rethrow;
  } finally {
    // نقفل الاتصالات بعد انتهاء الاختبار
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
