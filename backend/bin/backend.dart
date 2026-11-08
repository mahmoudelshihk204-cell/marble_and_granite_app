
import 'dart:io';
import 'package:oracledb/oracledb.dart';

Future<void> main() async {
  final host = Platform.environment['ORACLE_HOST'] ?? '127.0.0.1';
  final port = Platform.environment['ORACLE_PORT'] ?? '1521';
  final service =
      Platform.environment['ORACLE_SERVICE'] ?? 'PDBORCL';

  final user = Platform.environment['ORACLE_USER'] ?? 'MARBLE_APP';
  final password = Platform.environment['ORACLE_PASSWORD'] ?? '';

  if (password.isEmpty) {
    print('Error: ORACLE_PASSWORD is not configured.');
    return;
  }

  final connectString = '$host:$port/$service';

  OracleConnection? connection;

  try {
    print('Connecting to Oracle Database...');

    connection = await OracleConnection.connect(
      connectString,
      user: user,
      password: password,
      timeout: const Duration(seconds: 30),
    );

    print('Connected successfully!');

    print('\nReading products...');

    final result = await connection.execute('''
      SELECT PRODUCT_ID,
             PRODUCT_NAME,
             PRODUCED_QTY,
             SOLD_QTY,
             CENTRAL_STOCK_QTY
      FROM PRODUCTS
      ORDER BY PRODUCT_ID
    ''');

    print('\n========== PRODUCTS ==========');

    for (final row in result.rows) {
      print('''
Product ID: ${row['PRODUCT_ID']}
Name: ${row['PRODUCT_NAME']}
Produced: ${row['PRODUCED_QTY']}
Sold: ${row['SOLD_QTY']}
Central Stock: ${row['CENTRAL_STOCK_QTY']}
-------------------------------
''');
    }

    print('Total products retrieved: ${result.rows.length}');
    print('Database test completed successfully!');

  } catch (e) {
    print('\nDATABASE CONNECTION / QUERY ERROR:');
    print(e);
  } finally {
    if (connection != null) {
      await connection.close();
      print('\nOracle connection closed.');
    }
  }
}
