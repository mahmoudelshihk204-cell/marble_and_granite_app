
import 'package:backend/database/postgres_connection.dart';

Future<void> main() async {
  final database = PostgresDatabase();

  try {
    // فتح اتصال بقاعدة Supabase
    final connection = await database.connect();

    // التأكد من وجود جدول الأصناف وقراءة عدد السجلات
    final result = await connection.execute(
      'SELECT COUNT(*) FROM public.items',
    );

    final totalItems = result.first[0];

    print('\n========== ITEMS TABLE TEST ==========');
    print('Table: public.items');
    print('Total Items: $totalItems');
    print('======================================');
  } catch (error) {
    print('PostgreSQL test failed: $error');
  } finally {
    await database.close();
  }
}
