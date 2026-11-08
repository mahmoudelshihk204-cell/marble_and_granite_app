class ProductModel {
  final int productId;
  final String productName;
  final int producedQty;
  final int soldQty;
  final int centralStockQty;

  const ProductModel({
    required this.productId,
    required this.productName,
    required this.producedQty,
    required this.soldQty,
    required this.centralStockQty,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      producedQty: json['producedQty'] as int,
      soldQty: json['soldQty'] as int,
      centralStockQty: json['centralStockQty'] as int,
    );
  }
}
