
import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/postgres_connection.dart';
import 'package:postgres/postgres.dart';

const String testBarcode = '00022798';

// نفس الأعمدة المستخدمة في البحث الأساسي
const List<String> columns = [
  'ITEM_CODE',
  'ITEM_NAME',
  'ITEM_CODE2',
  'ITEM_NAME2',
  'ITEM_NAME_EN',
  'X',
  'Y',
  'Z',
  'M_CLASS',
  'M_TYPE',
  'M_NAME',
  'M_FINISH',
  'M_CLR',
  'M_FLAG',
  'CLASS_NAME',
  'TYPE_NAME',
  'MATERIAL_NAME',
  'FINISH_NAME',
  'SYS_DATE',
];

const Set<String> numericColumns = {'X', 'Y', 'Z'};

// استخراج ITEM_CODE من باركود EAN-8
// نفس قواعد التحقق الموجودة في LegacyItemApi
String? itemCodeFromEan8(String barcode) {
  final normalized = barcode.trim();

  // لازم يكون 8 أرقام بالضبط
  if (!RegExp(r'^\d{8}$').hasMatch(normalized)) {
    return null;
  }

  // أول 3 أرقام لازم تكون 000
  if (!normalized.startsWith('000')) {
    return null;
  }

  // حساب رقم التحقق EAN-8
  int sum = 0;

  for (int i = 0; i < 7; i++) {
    final digit = int.parse(normalized[i]);

    sum += digit * (i.isEven ? 3 : 1);
  }

  final checkDigit = (10 - (sum % 10)) % 10;
  final actualCheckDigit = int.parse(normalized[7]);

  if (checkDigit != actualCheckDigit) {
    return null;
  }

  // استخراج الأربع أرقام الخاصة بكود الصنف
  return normalized.substring(3, 7);
}

// مقارنة التاريخ
bool sameDate(Object? first, Object? second) {
  if (first == null || second == null) {
    return first == second;
  }

  final date1 = first is DateTime
      ? first
      : DateTime.tryParse(first.toString());

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

// مقارنة القيم
bool sameValue(String column, Object? first, Object? second) {
  if (first == null || second == null) {
    return first == second;
  }

  if (column == 'SYS_DATE') {
    return sameDate(first, second);
  }

  if (numericColumns.contains(column)) {
    final number1 = num.tryParse(first.toString());
    final number2 = num.tryParse(second.toString());

    if (number1 == null || number2 == null) {
      return first.toString() == second.toString();
    }

    return (number1 - number2).abs() <= 0.000000001;
  }

  return first.toString() == second.toString();
}

Future<void> main() async {
  // أولاً: اختبار صحة الباركود
  print('========== BARCODE VALIDATION ==========');

  final itemCode = itemCodeFromEan8(testBarcode);

  print('Barcode: $testBarcode');
  print('Extracted ITEM_CODE: $itemCode');

  if (itemCode == null) {
    throw Exception('Barcode validation failed!');
  }

  // اختبارات للباركود غير الصحيح
  final invalidBarcodes = [
    '0002279',  // أقل من 8 أرقام
    '000227981', // أكثر من 8 أرقام
    '12322798', // Prefix غير صحيح
    '00022799', // Check digit غير صحيح
    '00022A98', // يحتوي على حرف
  ];

  for (final barcode in invalidBarcodes) {
    if (itemCodeFromEan8(barcode) != null) {
      throw Exception('Invalid barcode accepted: $barcode');
    }
  }

  print('Valid barcode test: PASSED');
  print('Invalid barcode tests: ${invalidBarcodes.length} PASSED');

  final oracleDatabase = OracleDatabase();
  final postgresDatabase = PostgresDatabase();

  Connection? postgresConnection;

  try {
    final oracleConnection = await oracleDatabase.connect();
    postgresConnection = await postgresDatabase.connect();

    print('\n========== DATABASE SEARCH ==========');
    print('Searching using ITEM_CODE: $itemCode');

    // استعلام Oracle
    const oracleQuery = '''
      SELECT
        I.ITEM_CODE,
        I.ITEM_NAME,
        I.ITEM_CODE2,
        I.ITEM_NAME2,
        I.ITEM_NAME_EN,
        I.X, I.Y, I.Z,
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
      FROM EXP2013.INVMAS I
      LEFT JOIN EXP2013.PLOCK_INSX PC
        ON PC.GROUP_CODE = I.M_CLASS
      LEFT JOIN EXP2013.PLOCK_INSX PT
        ON PT.GROUP_CODE = I.M_TYPE
      LEFT JOIN EXP2013.PLOCK_INSX PN
        ON PN.GROUP_CODE = I.M_NAME
      LEFT JOIN EXP2013.PLOCK_INSX PF
        ON PF.GROUP_CODE = I.M_FINISH
      WHERE I.ITEM_CODE = :item_code
    ''';

    final oracleResult = await oracleConnection.execute(
      oracleQuery,
      {'item_code': itemCode},
    );

    // نفس الاستعلام على PostgreSQL
    const postgresQuery = '''
      SELECT
        i.item_code,
        i.item_name,
        i.item_code2,
        i.item_name2,
        i.item_name_en,
        i.x, i.y, i.z,
        i.m_class,
        i.m_type,
        i.m_name,
        i.m_finish,
        i.m_clr,
        i.m_flag,
        pc.group_name AS class_name,
        pt.group_name AS type_name,
        pn.group_name AS material_name,
        pf.group_name AS finish_name,
        i.sys_date
      FROM public.invmas i
      LEFT JOIN public.plock_insx pc
        ON pc.group_code = i.m_class
      LEFT JOIN public.plock_insx pt
        ON pt.group_code = i.m_type
      LEFT JOIN public.plock_insx pn
        ON pn.group_code = i.m_name
      LEFT JOIN public.plock_insx pf
        ON pf.group_code = i.m_finish
      WHERE i.item_code = @item_code
    ''';

    final postgresResult = await postgresConnection.execute(
      Sql.named(postgresQuery),
      parameters: {'item_code': itemCode},
    );

    print('Oracle results: ${oracleResult.rows.length}');
    print('PostgreSQL results: ${postgresResult.length}');

    if (oracleResult.rows.length != 1 ||
        postgresResult.length != 1) {
      throw Exception('Expected exactly one item in each database.');
    }

    final oracleData = oracleResult.rows.first.toMap();
    final postgresRow = postgresResult.first;

    int differences = 0;

    // مقارنة كل الأعمدة
    for (int i = 0; i < columns.length; i++) {
      final column = columns[i];

      final oracleValue = oracleData[column];
      final postgresValue = postgresRow[i];

      if (!sameValue(column, oracleValue, postgresValue)) {
        differences++;

        print('\nDIFFERENT | $column');
        print('Oracle: $oracleValue');
        print('PostgreSQL: $postgresValue');
      }
    }

    print('\n========== FINAL RESULT ==========');
    print('Barcode: $testBarcode');
    print('Extracted ITEM_CODE: $itemCode');
    print('Compared columns: ${columns.length}');
    print('Differences: $differences');

    if (differences == 0) {
      print('SUCCESS: Barcode search results match!');
    } else {
      print('FAILED: Differences were found.');
    }
  } catch (error) {
    print('\nBarcode verification failed: $error');
    rethrow;
  } finally {
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
