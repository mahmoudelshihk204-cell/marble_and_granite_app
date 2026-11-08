
import 'package:oracledb/oracledb.dart';
import '../config/database_config.dart';

class OracleDatabase {
  OracleConnection? _connection;

  Future<OracleConnection> connect() async {
    print('Connecting to Oracle...');

    _connection = await OracleConnection.connect(
      DatabaseConfig.connectionString,
      user: DatabaseConfig.username,
      password: DatabaseConfig.password,
      timeout: const Duration(seconds: 30),
    );

    print('Oracle connected successfully!');

    return _connection!;
  }

  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;

      print('Oracle connection closed.');
    }
  }
}
