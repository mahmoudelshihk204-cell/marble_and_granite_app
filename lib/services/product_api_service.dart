import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductApiService {
  static const String baseUrl = 'http://192.168.1.22:8080';

  Future<List<ProductModel>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final products = responseData['data'] as List;

        return products.map((product) {
          return ProductModel.fromJson(Map<String, dynamic>.from(product));
        }).toList();
      }

      throw Exception('Failed to fetch products');
    }

    throw Exception('Server Error: ${response.statusCode}');
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final url = Uri.parse(
      '$baseUrl/products/barcode/${Uri.encodeComponent(barcode)}',
    );

    final response = await http.get(url);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final productData = Map<String, dynamic>.from(responseData['data']);

        return ProductModel.fromJson(productData);
      }

      throw Exception('Failed to search product');
    }

    throw Exception('Server Error: ${response.statusCode}');
  }
}
