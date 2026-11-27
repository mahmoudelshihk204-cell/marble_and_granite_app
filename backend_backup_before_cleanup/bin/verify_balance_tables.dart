import 'package:oracledb/oracledb.dart';
import 'package:postgres/postgres.dart';

import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/postgres_connection.dart';

// ============================================================
// توحيد شكل البيانات قبل المقارنة
// ============================================================

Object? normalizeValue(Object? value) {
  if (value == null) return null;

  // Oracle DATE و PostgreSQL TIMESTAMP
  // بنقارن حتى مستوى الثانية، لأن Oracle DATE لا يخزن أجزاء الثانية.
  if (value is DateTime) {
    return '${value.year}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:'
        '${value.second.toString().padLeft(2, '0')}';
  }

  // مقارنة الأرقام بغض النظر عن كونها int أو double
  if (value is num) {
    return value;
  }

  // توحيد النصوص
  if (value is String) {
    return value.trim();
  }

  return value.toString();
}

// ============================================================
// إنشاء مفتاح مميز لكل سجل باستخدام الأعمدة المحددة
// ============================================================

String createKey(Map<String, dynamic> data, List<String> keyColumns) {
  return keyColumns
      .map((column) => normalizeValue(data[column])?.toString() ?? '<NULL>')
      .join('|');
}

// ============================================================
// مقارنة جدول Oracle بجدول PostgreSQL
// ============================================================

Future<void> verifyTable({
  required String tableName,
  required String oracleTableName,
  required List<String> columns,
  required List<String> keyColumns,
  required OracleConnection oracleConnection,
  required Connection postgresConnection,
}) async {
  print('\n======================================');
  print('Verifying $tableName');
  print('======================================');

  final columnList = columns.join(', ');

  // قراءة البيانات من Oracle
  final oracleQuery =
      '''
    SELECT $columnList
    FROM $oracleTableName
    ORDER BY ${keyColumns.join(', ')}
  ''';

  final oracleResult = await oracleConnection.execute(oracleQuery);
  final oracleRows = oracleResult.rows;

  // قراءة البيانات من PostgreSQL
  final postgresQuery =
      '''
    SELECT $columnList
    FROM public.$tableName
    ORDER BY ${keyColumns.join(', ')}
  ''';

  final postgresResult = await postgresConnection.execute(postgresQuery);
  final postgresRows = postgresResult.toList();

  print('Oracle records: ${oracleRows.length}');
  print('PostgreSQL records: ${postgresRows.length}');

  // ==========================================
  // تجهيز بيانات Oracle
  // ==========================================

  final oracleMap = <String, Map<String, dynamic>>{};

  for (final row in oracleRows) {
    final data = row.toMap();
    final key = createKey(data, keyColumns);

    oracleMap[key] = data;
  }

  // ==========================================
  // تجهيز بيانات PostgreSQL
  // ==========================================

  final postgresMap = <String, Map<String, dynamic>>{};

  for (final row in postgresRows) {
    final data = <String, dynamic>{};

    for (var i = 0; i < columns.length; i++) {
      data[columns[i]] = row[i];
    }

    final key = createKey(data, keyColumns);

    postgresMap[key] = data;
  }

  // ==========================================
  // المقارنة
  // ==========================================

  final missingRecords = <String>[];
  final extraRecords = <String>[];
  final differentRecords = <String>[];

  // البحث عن السجلات الموجودة في Oracle
  for (final key in oracleMap.keys) {
    // سجل موجود في Oracle وغير موجود في PostgreSQL
    if (!postgresMap.containsKey(key)) {
      missingRecords.add(key);
      continue;
    }

    final oracleData = oracleMap[key]!;
    final postgresData = postgresMap[key]!;

    // مقارنة كل الأعمدة
    for (final column in columns) {
      final oracleValue = normalizeValue(oracleData[column]);
      final postgresValue = normalizeValue(postgresData[column]);

      if (oracleValue != postgresValue) {
        differentRecords.add(
          '$key | Column: $column'
          ' | Oracle: $oracleValue'
          ' | PostgreSQL: $postgresValue',
        );
      }
    }
  }

  // البحث عن سجلات موجودة في PostgreSQL فقط
  for (final key in postgresMap.keys) {
    if (!oracleMap.containsKey(key)) {
      extraRecords.add(key);
    }
  }

  // ==========================================
  // عرض النتائج
  // ==========================================

  print('\n========== VERIFICATION RESULT ==========');
  print('Oracle records: ${oracleRows.length}');
  print('PostgreSQL records: ${postgresRows.length}');
  print('Missing records: ${missingRecords.length}');
  print('Extra records: ${extraRecords.length}');
  print('Different values: ${differentRecords.length}');
  print('====================================');

  // السجلات الناقصة
  if (missingRecords.isNotEmpty) {
    print('\nMissing records (first 10):');

    for (final key in missingRecords.take(10)) {
      print(key);
    }
  }

  // السجلات الزائدة
  if (extraRecords.isNotEmpty) {
    print('\nExtra records (first 10):');

    for (final key in extraRecords.take(10)) {
      print(key);
    }
  }

  // القيم المختلفة
  if (differentRecords.isNotEmpty) {
    print('\nDifferent values (first 20):');

    for (final difference in differentRecords.take(20)) {
      print(difference);
    }
  }

  // النتيجة النهائية
  if (missingRecords.isEmpty &&
      extraRecords.isEmpty &&
      differentRecords.isEmpty &&
      oracleRows.length == postgresRows.length) {
    print('\nSUCCESS: All $tableName records match!');
  } else {
    print('\nFAILED: $tableName data mismatch detected!');
  }
}

// ============================================================
// Main
// ============================================================

Future<void> main() async {
  final oracleDatabase = OracleDatabase();
  final postgresDatabase = PostgresDatabase();

  Connection? postgresConnection;

  try {
    // فتح اتصال Oracle مرة واحدة
    final oracleConnection = await oracleDatabase.connect();

    // فتح اتصال PostgreSQL مرة واحدة
    postgresConnection = await postgresDatabase.connect();

    // ==========================================
    // التحقق من BRANCH
    // ==========================================

    await verifyTable(
      tableName: 'branch',
      oracleTableName: 'EXP2013.BRANCH',
      columns: [
        'GROUP_CODE',
        'GROUP_NAME',
        'GROUP_MGR',
        'BR_CODE',
        'ACTIV_CODE',
        'SYS_DATE',
        'S_DELEV',
        'AUTO_MANUAL',
        'GROUP_NAME_TR',
        'GROUP_NAME_ES',
        'GROUP_NAME_IT',
        'GROUP_NAME_FR',
        'GROUP_NAME_DE',
        'GROUP_NAME_RU',
        'GROUP_NAME2',
        'MOV',
        'DEF_GROUP_CODE',
        'LINK_CODE',
        'SALE_TAX',
        'PUR_TAX',
        'PRT_REM',
        'IMAGE_HED',
        'IMAGE_FOD',
        'IMAGE_COVER',
        'DEAL_ITEM_EXP',
        'CUST_EMAIL',
        'CUST_EMAIL_PASS',
        'COMM_NO',
        'TAX_NO',
        'TAX_EMAIL',
        'MSG_SUB',
        'MSG_BODY',
        'LOCAL_CO_CODE',
        'BRAN_CODE_TYPE',
        'ORDER_NO',
        'RES',
        'IND_COST',
      ],
      keyColumns: ['GROUP_CODE'],
      oracleConnection: oracleConnection,
      postgresConnection: postgresConnection,
    );

    // ==========================================
    // التحقق من INVMAS_BAL
    // ==========================================

    await verifyTable(
      tableName: 'invmas_bal',
      oracleTableName: 'EXP2013.INVMAS_BAL',
      columns: [
        'ITEM_CODE',
        'BRAN_CODE',
        'RAIS',
        'RE_DEM',
        'SYS_DATE',
        'BAL',
        'NBAL',
      ],
      keyColumns: ['ITEM_CODE', 'BRAN_CODE'],
      oracleConnection: oracleConnection,
      postgresConnection: postgresConnection,
    );
  } catch (error) {
    print('\nVerification failed: $error');
  } finally {
    // إغلاق الاتصالات
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
