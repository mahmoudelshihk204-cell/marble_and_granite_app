// Model بيمثل بيانات الصنف المستخرجة من قاعدة البيانات الأصلية.
//
// بنستخدم String للأكواد لأن Oracle مخزنها VARCHAR2،
// وبنستخدم num للأبعاد عشان نحافظ على القيم العشرية.

class LegacyItemModel {
  final String itemCode;
  final String? itemName;
  final String? alternateCode;
  final String? itemName2;
  final String? itemNameEn;

  // أبعاد الصنف
  final num? x;
  final num? y;
  final num? z;

  // أكواد التصنيفات الأصلية
  final String? classCode;
  final String? typeCode;
  final String? materialCode;
  final String? finishCode;
  final String? colorCode;
  final String? flagCode;

  // أسماء التصنيفات بعد الربط مع PLOCK_INSX
  final String? className;
  final String? typeName;
  final String? materialName;
  final String? finishName;

  final DateTime? systemDate;

  const LegacyItemModel({
    required this.itemCode,
    this.itemName,
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

  // تحويل قيمة Oracle إلى String مع التعامل مع NULL.
  static String? _stringValue(Object? value) {
    if (value == null) return null;
    return value.toString();
  }

  // تحويل القيمة الرقمية مع الحفاظ على NULL.
  static num? _numberValue(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  // تحويل تاريخ Oracle إلى DateTime.
  static DateTime? _dateValue(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  // Model بيمثل بيانات الصنف المستخرجة من قاعدة البيانات الأصلية.
  //
  // بنستخدم String للأكواد لأن Oracle مخزنها VARCHAR2،

  // تحويل بيانات Oracle إلى Model خاص بالصنف.
  factory LegacyItemModel.fromMap(Map<String, dynamic> map) {
    // نتأكد إن كود الصنف موجود قبل إنشاء الـ Model.
    final itemCodeValue = map['ITEM_CODE'];

    if (itemCodeValue == null) {
      throw const FormatException('ITEM_CODE is missing');
    }

    return LegacyItemModel(
      itemCode: itemCodeValue.toString(),
      itemName: _stringValue(map['ITEM_NAME']),
      alternateCode: _stringValue(map['ITEM_CODE2']),
      itemName2: _stringValue(map['ITEM_NAME2']),
      itemNameEn: _stringValue(map['ITEM_NAME_EN']),

      x: _numberValue(map['X']),
      y: _numberValue(map['Y']),
      z: _numberValue(map['Z']),

      classCode: _stringValue(map['M_CLASS']),
      typeCode: _stringValue(map['M_TYPE']),
      materialCode: _stringValue(map['M_NAME']),
      finishCode: _stringValue(map['M_FINISH']),
      colorCode: _stringValue(map['M_CLR']),
      flagCode: _stringValue(map['M_FLAG']),

      className: _stringValue(map['CLASS_NAME']),
      typeName: _stringValue(map['TYPE_NAME']),
      materialName: _stringValue(map['MATERIAL_NAME']),
      finishName: _stringValue(map['FINISH_NAME']),

      systemDate: _dateValue(map['SYS_DATE']),
    );
  }

  // تحويل البيانات إلى JSON لإرسالها إلى Flutter.
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
