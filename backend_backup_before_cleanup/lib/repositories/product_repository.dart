import 'package:oracledb/oracledb.dart';
import '../models/product_model.dart';

class ProductRepository {
  final OracleConnection connection;

  ProductRepository({required this.connection});

  Future<List<ProductModel>> getAllProducts() async {
    const query = '''
      SELECT PRODUCT_ID,
             PRODUCT_NAME,
             PRODUCED_QTY,
             SOLD_QTY,
             CENTRAL_STOCK_QTY
      FROM PRODUCTS
      ORDER BY PRODUCT_ID
    ''';

    final result = await connection.execute(query);

    return result.rows.map((row) {
      return ProductModel.fromRow(row);
    }).toList();
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    const query = '''
    SELECT PRODUCT_ID,
           PRODUCT_NAME,
           PRODUCED_QTY,
           SOLD_QTY,
           CENTRAL_STOCK_QTY
    FROM PRODUCTS
    WHERE BARCODE = :barcode
  ''';

    final result = await connection.execute(query, {'barcode': barcode});

    if (result.rows.isEmpty) {
      return null;
    }

    return ProductModel.fromRow(result.rows.first);
  }
}
