
import 'package:oracledb/oracledb.dart';

import '../database/oracle_operation_queue.dart';

class AuthRepository {
  final OracleConnection connection;
  final OracleOperationQueue queue;

  AuthRepository({
    required this.connection,
    required this.queue,
  });

  // التحقق من بيانات الموظف باستخدام PAS و PASS_WORD
  Future<Map<String, dynamic>?> authenticate({
    required String username,
    required String password,
  }) async {
    const query = '''
      SELECT
        EMP_NO,
        EMP_NA,
        PAS,
        JOB,
        BR_CODE,
        EMP_BRAN_CODE,
        DEF_LANG
      FROM PAS
      WHERE PAS = :username
        AND PASS_WORD = :password
    ''';

    return queue.run(() async {
      final result = await connection.execute(query, {
        'username': username,
        'password': password,
      });

      // لو مفيش سجل مطابق، بيانات الدخول غير صحيحة
      if (result.rows.isEmpty) {
        return null;
      }

      // بنرجع بيانات الموظف فقط، من غير كلمة المرور
      return result.rows.first.toMap();
    });
  }
}
