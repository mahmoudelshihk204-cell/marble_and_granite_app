// ignore_for_file: avoid_print

import '../lib/services/product_api_service.dart';

Future<void> main() async {
  final service = ProductApiService();

  // Test 1: Existing barcode
  print('Testing existing barcode...');

  final product = await service.getProductByBarcode('622100000001');

  if (product != null) {
    print('Product Found!');
    print('Name: ${product.productName}');
    print('Produced: ${product.producedQty}');
    print('Sold: ${product.soldQty}');
    print('Central Stock: ${product.centralStockQty}');
  } else {
    print('Product not found!');
  }

  print('\n-------------------------\n');

  // Test 2: Non-existing barcode
  print('Testing non-existing barcode...');

  final notFound = await service.getProductByBarcode('999999999999');

  if (notFound == null) {
    print('Test Successful: Product not found as expected.');
  } else {
    print('Test Failed: Unexpected product found!');
  }
}
