import 'package:backend/database/oracle_connection.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    // الاتصال بقاعدة البيانات
    final connection = await database.connect();

    // استعلام قراءة فقط للتأكد من الاتصال ووجود بيانات الأصناف
    const query = '''
      SELECT
        USER AS CONNECTED_USER,
        SYS_CONTEXT('USERENV', 'SERVICE_NAME') AS SERVICE_NAME,
        (SELECT COUNT(*) FROM INVMAS) AS TOTAL_ITEMS
      FROM DUAL
    ''';

    final result = await connection.execute(query);

    print('');
    print('========== DATABASE TEST ==========');
    // عرض كل قيمة من الصف بشكل منفصل
    final row = result.rows.first;

    print('CONNECTED_USER: ${row['CONNECTED_USER']}');
    print('SERVICE_NAME: ${row['SERVICE_NAME']}');
    print('TOTAL_ITEMS: ${row['TOTAL_ITEMS']}');
    print('===================================');
  } catch (error) {
    print('Database test failed: $error');
  } finally {
    // إغلاق الاتصال بعد انتهاء الاختبار
    await database.close();
  }
}
