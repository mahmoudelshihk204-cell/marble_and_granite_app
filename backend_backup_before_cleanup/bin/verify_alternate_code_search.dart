import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/postgres_connection.dart';
import 'package:postgres/postgres.dart';

const String testAlternateCode = '32796';

// الأعمدة اللي هنقارنها، بنفس ترتيب استعلام البحث
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
  final oracleDatabase = OracleDatabase();
  final postgresDatabase = PostgresDatabase();

  Connection? postgresConnection;

  try {
    final oracleConnection = await oracleDatabase.connect();
    postgresConnection = await postgresDatabase.connect();

    print('\nTesting alternate code search...');
    print('ITEM_CODE2: $testAlternateCode');

    // استعلام Oracle بنفس منطق البحث الموجود في التطبيق
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
      WHERE I.ITEM_CODE2 = :alternate_code
      ORDER BY I.ITEM_CODE
    ''';

    final oracleResult = await oracleConnection.execute(oracleQuery, {
      'alternate_code': testAlternateCode,
    });

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
      WHERE i.item_code2 = @alternate_code
      ORDER BY i.item_code
    ''';

    final postgresResult = await postgresConnection.execute(
      Sql.named(postgresQuery),
      parameters: {'alternate_code': testAlternateCode},
    );

    print('Oracle results: ${oracleResult.rows.length}');
    print('PostgreSQL results: ${postgresResult.length}');

    int totalDifferences = 0;

    // لازم عدد النتائج يكون متساوي
    if (oracleResult.rows.length != postgresResult.length) {
      print('\nDIFFERENT: Result counts do not match.');
      totalDifferences++;
    }

    // مقارنة كل نتيجة بنظيرتها بعد ترتيب ITEM_CODE
    final commonLength = oracleResult.rows.length < postgresResult.length
        ? oracleResult.rows.length
        : postgresResult.length;

    for (int rowIndex = 0; rowIndex < commonLength; rowIndex++) {
      final oracleData = oracleResult.rows[rowIndex].toMap();
      final postgresRow = postgresResult[rowIndex];

      final itemCode = oracleData['ITEM_CODE'];

      print('\nComparing ITEM_CODE: $itemCode');

      for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        final column = columns[columnIndex];

        final oracleValue = oracleData[column];
        final postgresValue = postgresRow[columnIndex];

        if (!sameValue(column, oracleValue, postgresValue)) {
          totalDifferences++;

          print('DIFFERENT | $column');
          print('  Oracle     : $oracleValue');
          print('  PostgreSQL : $postgresValue');
        }
      }
    }

    print('\n========== ALTERNATE SEARCH RESULT ==========');
    print('Oracle records      : ${oracleResult.rows.length}');
    print('PostgreSQL records  : ${postgresResult.length}');
    print('Compared records    : $commonLength');
    print('Differences         : $totalDifferences');
    print('=============================================');

    if (oracleResult.rows.length == postgresResult.length &&
        totalDifferences == 0) {
      print('\nSUCCESS: Alternate code search results match!');
    } else {
      print('\nVERIFICATION FAILED: Differences were found.');
    }
  } catch (error) {
    print('\nAlternate code verification failed: $error');
    rethrow;
  } finally {
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
