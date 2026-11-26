import 'barcode_warehouse_balance_model.dart';

class LegacyItemModel {
  final String itemCode;
  final String? alternateCode;

  final String itemName;
  final String? itemName2;
  final String? itemNameEn;

  final double? x;
  final double? y;
  final double? z;

  final String? classCode;
  final String? typeCode;
  final String? materialCode;
  final String? finishCode;
  final String? colorCode;
  final String? flagCode;

  final String? className;
  final String? typeName;
  final String? materialName;
  final String? finishName;

  final DateTime? systemDate;

  // بيانات الوحدة والسعر القادمة من Barcode API.
  final String? unitName;
  final String? unitCode;
  final double? price;

  // إجماليات TopSoftware كما وصلت، دون افتراض معناها.
  final double? totalOverBlock;
  final double? totalOverCompany;

  // أرصدة المستودعات وعدد القطع.
  final List<BarcodeWarehouseBalanceModel> warehouseBalances;

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
    this.unitName,
    this.unitCode,
    this.price,
    this.totalOverBlock,
    this.totalOverCompany,
    this.warehouseBalances = const [],
  });

  factory LegacyItemModel.fromJson(Map<String, dynamic> json) {
    // التعامل مع البيانات سواء وصلت مباشرة أو داخل metaData.
    final data = json['metaData'] is Map
        ? Map<String, dynamic>.from(json['metaData'])
        : json['data'] is Map && (json['data'] as Map)['metaData'] is Map
        ? Map<String, dynamic>.from((json['data'] as Map)['metaData'])
        : json;

    if (data['itemCode'] == null) {
      throw const FormatException('itemCode is missing');
    }

    if (data['itemName'] == null) {
      throw const FormatException('itemName is missing');
    }

    // قراءة جدول المستودعات القادم من TopSoftware.
    final rawTable = data['table'];
    final warehouses = rawTable is List
        ? rawTable
              .whereType<Map>()
              .map(
                (row) => BarcodeWarehouseBalanceModel.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList()
        : <BarcodeWarehouseBalanceModel>[];

    // قراءة الاسم الإنجليزي من اللغات إذا كان متاحًا فعلًا.
    final languages = data['itemNameLanguages'];
    final englishName = languages is Map ? _stringValue(languages['En']) : null;

    return LegacyItemModel(
      itemCode: data['itemCode'].toString(),
      itemName: data['itemName'].toString(),

      // TopSoftware بيرجع رقم البلوك باسم blockNumber.
      alternateCode: _stringValue(data['blockNumber'] ?? data['alternateCode']),
      itemName2: _stringValue(data['itemName2']),
      itemNameEn: englishName == '0' ? null : englishName,

      x: _numberValue(data['x'] ?? data['xdimension']),
      y: _numberValue(data['y'] ?? data['ydimension']),
      z: _numberValue(data['z'] ?? data['zdimension']),

      classCode: _stringValue(data['classCode']),
      typeCode: _stringValue(data['typeCode']),
      materialCode: _stringValue(data['materialCode']),
      finishCode: _stringValue(data['finishCode']),
      colorCode: _stringValue(data['colorCode']),
      flagCode: _stringValue(data['flagCode']),

      className: _stringValue(data['className']),
      typeName: _stringValue(data['typeName']),
      materialName: _stringValue(data['materialName']),
      finishName: _stringValue(data['finishName']),

      systemDate: _dateValue(data['systemDate']),

      unitName: _stringValue(data['unit']),
      unitCode: _stringValue(data['unitCode']),
      price: _numberValue(data['price']),

      totalOverBlock: _numberValue(data['totalOverBlock']),
      totalOverCompany: _numberValue(data['totalOverCompany']),

      warehouseBalances: warehouses,
    );
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static double? _numberValue(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

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
      'unit': unitName,
      'unitCode': unitCode,
      'price': price,
      'totalOverBlock': totalOverBlock,
      'totalOverCompany': totalOverCompany,
      'table': warehouseBalances.map((e) => e.toJson()).toList(),
    };
  }
}
