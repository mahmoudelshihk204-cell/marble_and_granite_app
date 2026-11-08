class ProductModel {
  final int productId;
  final String productName;
  final int producedQty;
  final int soldQty;
  final int centralStockQty;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.producedQty,
    required this.soldQty,
    required this.centralStockQty,
  });

  factory ProductModel.fromRow(dynamic row) {
    return ProductModel(
      productId: (row['PRODUCT_ID'] as num).toInt(),
      productName: row['PRODUCT_NAME'].toString(),
      producedQty: (row['PRODUCED_QTY'] as num).toInt(),
      soldQty: (row['SOLD_QTY'] as num).toInt(),
      centralStockQty: (row['CENTRAL_STOCK_QTY'] as num).toInt(),
    );
  }
  Map<String, dynamic> toJson() {
  return {
    'productId': productId,
    'productName': productName,
    'producedQty': producedQty,
    'soldQty': soldQty,
    'centralStockQty': centralStockQty,
  };
}
}
