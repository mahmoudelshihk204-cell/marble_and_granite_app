
class LegacyItemModel {
  // كود الصنف الأساسي والكود البديل
  final String itemCode;
  final String? alternateCode;

  // أسماء الصنف
  final String itemName;
  final String? itemName2;
  final String? itemNameEn;

  // أبعاد الصنف
  final double? x;
  final double? y;
  final double? z;

  // أكواد التصنيف
  final String? classCode;
  final String? typeCode;
  final String? materialCode;
  final String? finishCode;
  final String? colorCode;
  final String? flagCode;

  // أسماء التصنيفات
  final String? className;
  final String? typeName;
  final String? materialName;
  final String? finishName;

  // تاريخ آخر تحديث
  final DateTime? systemDate;

  const LegacyItemModel({
    required this.itemCode,
    required this.itemName,
    this.alternateCode,
    this.itemName2,
    this.itemNameEn,
    this.x,
    this.y,
    this.z,
    this.classCode,
    this.typeCode,
    this.materialCode,
    this.finishCode,
    this.colorCode,
    this.flagCode,
    this.className,
    this.typeName,
    this.materialName,
    this.finishName,
    this.systemDate,
  });

  // تحويل JSON القادم من السيرفر إلى Dart Object
  factory LegacyItemModel.fromJson(Map<String, dynamic> json) {
    // كود الصنف واسمه حقول أساسية ولازم يكونوا موجودين
    if (json['itemCode'] == null) {
      throw const FormatException('itemCode is missing');
    }

    if (json['itemName'] == null) {
      throw const FormatException('itemName is missing');
    }

    return LegacyItemModel(
      itemCode: json['itemCode'].toString(),
      itemName: json['itemName'].toString(),
      alternateCode: _stringValue(json['alternateCode']),
      itemName2: _stringValue(json['itemName2']),
      itemNameEn: _stringValue(json['itemNameEn']),
      x: _numberValue(json['x']),
      y: _numberValue(json['y']),
      z: _numberValue(json['z']),
      classCode: _stringValue(json['classCode']),
      typeCode: _stringValue(json['typeCode']),
      materialCode: _stringValue(json['materialCode']),
      finishCode: _stringValue(json['finishCode']),
      colorCode: _stringValue(json['colorCode']),
      flagCode: _stringValue(json['flagCode']),
      className: _stringValue(json['className']),
      typeName: _stringValue(json['typeName']),
      materialName: _stringValue(json['materialName']),
      finishName: _stringValue(json['finishName']),
      systemDate: _dateValue(json['systemDate']),
    );
  }

  // تحويل القيم النصية مع التعامل مع null
  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // تحويل الأرقام سواء وصلت int أو double أو String
  static double? _numberValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  // تحويل التاريخ مع تجنب الخطأ لو القيمة غير صالحة
  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  // تحويل الـ Object مرة أخرى إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'alternateCode': alternateCode,
      'itemName2': itemName2,
      'itemNameEn': itemNameEn,
      'x': x,
      'y': y,
      'z': z,
      'classCode': classCode,
      'typeCode': typeCode,
      'materialCode': materialCode,
      'finishCode': finishCode,
      'colorCode': colorCode,
      'flagCode': flagCode,
      'className': className,
      'typeName': typeName,
      'materialName': materialName,
      'finishName': finishName,
      'systemDate': systemDate?.toIso8601String(),
    };
  }
}
