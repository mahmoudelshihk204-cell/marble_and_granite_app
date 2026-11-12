
class LegacyUnitModel {
  // كود الصنف وكود وحدة القياس
  final String itemCode;
  final String unitCode;

  // أسماء وحدات القياس
  final String? unitName;
  final String? secondaryUnitName;

  // الأسعار والتكاليف
  final double? costPrice;
  final double? wholesalePrice;
  final double? salePrice;
  final double? averageCost;

  // بيانات التحويل بين الوحدات
  final bool isMasterUnit;
  final String? balanceUnitCode;
  final double? conversionValue;
  final double? unitValue;

  const LegacyUnitModel({
    required this.itemCode,
    required this.unitCode,
    this.unitName,
    this.secondaryUnitName,
    this.costPrice,
    this.wholesalePrice,
    this.salePrice,
    this.averageCost,
    required this.isMasterUnit,
    this.balanceUnitCode,
    this.conversionValue,
    this.unitValue,
  });

  // تحويل JSON القادم من السيرفر إلى Dart Object
  factory LegacyUnitModel.fromJson(Map<String, dynamic> json) {
    if (json['itemCode'] == null) {
      throw const FormatException('itemCode is missing');
    }

    if (json['unitCode'] == null) {
      throw const FormatException('unitCode is missing');
    }

    return LegacyUnitModel(
      itemCode: json['itemCode'].toString(),
      unitCode: json['unitCode'].toString(),
      unitName: _stringValue(json['unitName']),
      secondaryUnitName: _stringValue(json['secondaryUnitName']),
      costPrice: _numberValue(json['costPrice']),
      wholesalePrice: _numberValue(json['wholesalePrice']),
      salePrice: _numberValue(json['salePrice']),
      averageCost: _numberValue(json['averageCost']),
      isMasterUnit: _boolValue(json['isMasterUnit']),
      balanceUnitCode: _stringValue(json['balanceUnitCode']),
      conversionValue: _numberValue(json['conversionValue']),
      unitValue: _numberValue(json['unitValue']),
    );
  }

  // تحويل القيم النصية
  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // تحويل الأرقام إلى double
  static double? _numberValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // تحويل القيمة إلى Boolean
  static bool _boolValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value.toString().toLowerCase();
    return text == 'true' || text == '1' || text == 'y';
  }

  // تحويل Dart Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'unitCode': unitCode,
      'unitName': unitName,
      'secondaryUnitName': secondaryUnitName,
      'costPrice': costPrice,
      'wholesalePrice': wholesalePrice,
      'salePrice': salePrice,
      'averageCost': averageCost,
      'isMasterUnit': isMasterUnit,
      'balanceUnitCode': balanceUnitCode,
      'conversionValue': conversionValue,
      'unitValue': unitValue,
    };
  }
}
