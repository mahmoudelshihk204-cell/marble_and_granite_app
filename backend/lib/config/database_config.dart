

import 'dart:io';

class DatabaseConfig {
  static String get host =>
      Platform.environment['ORACLE_HOST'] ?? '127.0.0.1';

  static String get port =>
      Platform.environment['ORACLE_PORT'] ?? '1521';

  static String get service =>
      Platform.environment['ORACLE_SERVICE'] ?? 'PDBORCL';

  static String get username =>
      Platform.environment['ORACLE_USER'] ?? 'MARBLE_APP';

  static String get password =>
      Platform.environment['ORACLE_PASSWORD'] ?? '';

  static String get connectionString {
    return '$host:$port/$service';
  }
}

