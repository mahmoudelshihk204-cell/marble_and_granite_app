
class BarcodeWarehouseBalanceModel {
  final String? warehouseName;
  final String? warehouseCode;

  // كمية الصنف الموجودة في المستودع.
  final double? amount;

  // عدد قطع الصنف.
  final double? itemCount;

  const BarcodeWarehouseBalanceModel({
    this.warehouseName,
    this.warehouseCode,
    this.amount,
    this.itemCount,
  });

  factory BarcodeWarehouseBalanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BarcodeWarehouseBalanceModel(
      warehouseName: json['brandName']?.toString(),
      warehouseCode: json['brandCode']?.toString(),
      amount: _toDouble(json['amount']),
      itemCount: _toDouble(json['number']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'brandName': warehouseName,
      'brandCode': warehouseCode,
      'amount': amount,
      'number': itemCount,
    };
  }
}

