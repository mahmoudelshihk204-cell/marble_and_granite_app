
import 'dart:io';

class DatabaseConfig {
  // إعدادات الاتصال بقاعدة البيانات الأصلية المستوردة
  static String get host =>
      Platform.environment['ORACLE_HOST'] ?? '127.0.0.1';

  static String get port =>
      Platform.environment['ORACLE_PORT'] ?? '1522';

  static String get service =>
      Platform.environment['ORACLE_SERVICE'] ?? 'FREEPDB1';

  static String get username =>
      Platform.environment['ORACLE_USER'] ?? 'EXP2013';

  // كلمة المرور بتتقرأ من متغير بيئة، مش من الكود
  static String get password =>
      Platform.environment['ORACLE_PASSWORD'] ?? '';

  static String get connectionString => '$host:$port/$service';
}

