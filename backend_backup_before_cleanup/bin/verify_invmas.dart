import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/postgres_connection.dart';
import 'package:postgres/postgres.dart';

// الأعمدة الـ52 الموجودة في الجدولين
const List<String> columns = [
  'ITEM_CODE',
  'ITEM_NAME',
  'REM',
  'GROUP_CODE',
  'ACTIV_CODE',
  'SYS_DATE',
  'ITEM_CODE2',
  'ITEM_NAME2',
  'ITEM_EXP',
  'ITEM_STOR',
  'MULTI_CODE',
  'ITEM_NAME_EN',
  'ITEM_NAME_TR',
  'ITEM_NAME_ES',
  'ITEM_NAME_IT',
  'ITEM_NAME_FR',
  'ITEM_NAME_DE',
  'ITEM_NAME_RU',
  'PROD',
  'REM2',
  'Z',
  'X',
  'Y',
  'M_CLASS',
  'M_TYPE',
  'M_NAME',
  'M_FINISH',
  'M_CLR',
  'M_FLAG',
  'BR_CODE',
  'FRZ',
  'ITEM_CODEX',
  'SUP_CODE',
  'PLOCK_LINK',
  'AUTO_CR',
  'DOC_ATTX1',
  'DOC_ATTX2',
  'M_STEL',
  'EXP_PROD',
  'UNIT_CODED',
  'EXP_PER',
  'UNIT_CODED2',
  'ACTIV_FLW',
  'RPLC_SPAR',
  'ACC_CODE',
  'CUST_TYPE',
  'COST_C',
  'COST_C2',
  'PER_NO2',
  'PART_NO',
  'ITEM_TAX',
  'ITEM_TAX_TYPE',
];

// الأعمدة الرقمية التي سنقارنها كأرقام
const Set<String> numericColumns = {
  'Z',
  'X',
  'Y',
  'EXP_PROD',
  'EXP_PER',
  'PART_NO',
};

// مقارنة التواريخ مع تجاهل اختلاف تمثيل المنطقة الزمنية
bool sameDate(Object? first, Object? second) {
  if (first == null || second == null) {
    return first == second;
  }

  final date1 = first is DateTime ? first : DateTime.tryParse(first.toString());

  final date2 = second is DateTime
      ? second
      : DateTime.tryParse(second.toString());

  if (date1 == null || date2 == null) {
    return first.toString() == second.toString();
  }

  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day &&
      date1.hour == date2.hour &&
      date1.minute == date2.minute &&
      date1.second == date2.second;
}

// مقارنة قيم الأعمدة حسب نوعها
bool sameValue(String column, Object? oracleValue, Object? postgresValue) {
  // التأكد من تطابق القيم الفارغة
  if (oracleValue == null || postgresValue == null) {
    return oracleValue == postgresValue;
  }

  // مقارنة التاريخ
  if (column == 'SYS_DATE') {
    return sameDate(oracleValue, postgresValue);
  }

  // مقارنة الأرقام مع السماح بفارق دقة حسابي ضئيل جدًا
  if (numericColumns.contains(column)) {
    final number1 = num.tryParse(oracleValue.toString());
    final number2 = num.tryParse(postgresValue.toString());

    if (number1 == null || number2 == null) {
      return oracleValue.toString() == postgresValue.toString();
    }

    return (number1 - number2).abs() <= 0.000000001;
  }

  // مقارنة النصوص كما هي، بما فيها اللغة العربية
  return oracleValue.toString() == postgresValue.toString();
}

Future<void> main() async {
  final oracleDatabase = OracleDatabase();
  final postgresDatabase = PostgresDatabase();

  Connection? postgresConnection;

  try {
    // 1. فتح الاتصالين
    final oracleConnection = await oracleDatabase.connect();
    postgresConnection = await postgresDatabase.connect();

    print('\nStarting INVMAS verification...');

    // 2. قراءة بيانات Oracle
    final oracleQuery =
        '''
      SELECT ${columns.join(', ')}
      FROM EXP2013.INVMAS
      ORDER BY ITEM_CODE
    ''';

    final oracleResult = await oracleConnection.execute(oracleQuery);
    final oracleRows = oracleResult.rows;

    print('Oracle records: ${oracleRows.length}');

    // 3. قراءة بيانات PostgreSQL
    final postgresColumns = columns
        .map((column) => column.toLowerCase())
        .join(', ');

    final postgresQuery =
        '''
      SELECT $postgresColumns
      FROM public.invmas
      ORDER BY item_code
    ''';

    final postgresResult = await postgresConnection.execute(postgresQuery);

    // تخزين سجلات PostgreSQL باستخدام ITEM_CODE كمفتاح
    final postgresData = <String, List<dynamic>>{};

    for (final row in postgresResult) {
      final itemCode = row[0].toString();

      if (postgresData.containsKey(itemCode)) {
        throw Exception('Duplicate ITEM_CODE in PostgreSQL: $itemCode');
      }

      postgresData[itemCode] = List<dynamic>.generate(
        columns.length,
        (index) => row[index],
      );
    }

    print('PostgreSQL records: ${postgresData.length}');

    // 4. تجهيز عدادات نتائج المقارنة
    final columnErrors = <String, int>{};
    final printedErrors = <String>[];

    int comparedRecords = 0;
    int missingRecords = 0;
    int totalDifferences = 0;

    // 5. مقارنة كل سجل وكل عمود
    for (final oracleRow in oracleRows) {
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

        if (!sameValue(column, oracleValue, postgresValue)) {
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

    // 6. التأكد من عدم وجود سجلات إضافية في PostgreSQL
    int extraRecords = 0;

    final oracleCodes = oracleRows
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

    // 7. عرض النتيجة
    print('\n========== VERIFICATION RESULT ==========');
    print('Oracle records       : ${oracleRows.length}');
    print('PostgreSQL records   : ${postgresData.length}');
    print('Compared records     : $comparedRecords');
    print('Missing records      : $missingRecords');
    print('Extra records        : $extraRecords');
    print('Different values     : $totalDifferences');
    print('==========================================');

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
        oracleRows.length == postgresData.length) {
      print('\nSUCCESS: All INVMAS records match!');
    } else {
      print('\nVERIFICATION FAILED: Differences were found.');
    }
  } catch (error) {
    print('\nVerification failed: $error');
    rethrow;
  } finally {
    // 8. إغلاق الاتصالات
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
