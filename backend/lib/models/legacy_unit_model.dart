
// بيانات وحدة الصنف وأسعاره.
class LegacyUnitModel {
  final String itemCode;
  final String unitCode;
  final String? unitName;
  final String? secondaryUnitName;

  // الأسعار والتكلفة
  final num? costPrice;
  final num? wholesalePrice;
  final num? salePrice;
  final num? averageCost;

  // بيانات التحويل بين الوحدات
  final bool isMasterUnit;
  final String? balanceUnitCode;
  final num? conversionValue;
  final num? unitValue;

  const LegacyUnitModel({
    required this.itemCode,
    required this.unitCode,
    this.unitName,
    this.secondaryUnitName,
    this.costPrice,
    this.wholesalePrice,
    this.salePrice,
    this.averageCost,
    this.isMasterUnit = false,
    this.balanceUnitCode,
    this.conversionValue,
    this.unitValue,
  });

  static String? _stringValue(Object? value) {
    return value?.toString();
  }

  static num? _numberValue(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  
  // تحويل قيمة Oracle إلى Boolean.
// في البيانات الحالية القيمة 1 معناها وحدة أساسية.
static bool _boolValue(Object? value) {
  final normalized = value?.toString().trim().toUpperCase();

  return normalized == '1' || normalized == 'Y';
}

  // تحويل بيانات الوحدة والأسعار القادمة من Oracle إلى Model.
  factory LegacyUnitModel.fromMap(Map<String, dynamic> map) {
    // نتأكد إن كود الصنف وكود الوحدة موجودين.
    final itemCodeValue = map['ITEM_CODE'];
    final unitCodeValue = map['UNIT_CODE'];

    if (itemCodeValue == null) {
      throw const FormatException('ITEM_CODE is missing');
    }

    if (unitCodeValue == null) {
      throw const FormatException('UNIT_CODE is missing');
    }

    return LegacyUnitModel(
      itemCode: itemCodeValue.toString(),
      unitCode: unitCodeValue.toString(),
      unitName: _stringValue(map['UNIT_NAME']),
      secondaryUnitName: _stringValue(map['UNIT_NAME2']),

      costPrice: _numberValue(map['COST_PRICE']),
      wholesalePrice: _numberValue(map['WHOL_PRICE']),
      salePrice: _numberValue(map['SALE_PRICE']),
      averageCost: _numberValue(map['AVR_COST']),

      isMasterUnit: _boolValue(map['UNIT_MASTER']),
      balanceUnitCode: _stringValue(map['BAL_UNIT_CODE']),
      conversionValue: _numberValue(map['CONV_VAL']),
      unitValue: _numberValue(map['UNIT_VAL']),
    );
  }


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
