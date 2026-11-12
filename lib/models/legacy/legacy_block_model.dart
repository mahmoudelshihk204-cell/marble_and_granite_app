
class LegacyBlockModel {
  final LegacyBlockSummaryModel summary;
  final List<LegacyWarehouseTotalModel> warehouseTotals;
  final List<LegacyBlockSlabModel> slabs;

  const LegacyBlockModel({
    required this.summary,
    required this.warehouseTotals,
    required this.slabs,
  });

  // تحويل استجابة السيرفر إلى موديل البلوك
  factory LegacyBlockModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = _mapValue(json['summary']);

    final warehousesJson = json['warehouseTotals'] as List? ?? [];
    final slabsJson = json['slabs'] as List? ?? [];

    return LegacyBlockModel(
      summary: LegacyBlockSummaryModel.fromJson(summaryJson),
      warehouseTotals: warehousesJson
          .map((item) => LegacyWarehouseTotalModel.fromJson(
                _mapValue(item),
              ))
          .toList(),
      slabs: slabsJson
          .map((item) => LegacyBlockSlabModel.fromJson(
                _mapValue(item),
              ))
          .toList(),
    );
  }

  static Map<String, dynamic> _mapValue(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw const FormatException('Invalid object in block response');
  }
}

// ملخص بيانات البلوك
class LegacyBlockSummaryModel {
  final String blockNumber;
  final int slabCount;
  final double totalBalance;

  const LegacyBlockSummaryModel({
    required this.blockNumber,
    required this.slabCount,
    required this.totalBalance,
  });

  factory LegacyBlockSummaryModel.fromJson(Map<String, dynamic> json) {
    return LegacyBlockSummaryModel(
      blockNumber: json['blockNumber']?.toString() ?? '',
      slabCount: _intValue(json['slabCount']),
      totalBalance: _numberValue(json['totalBalance']),
    );
  }
}

// إجمالي رصيد البلوك في كل مستودع
class LegacyWarehouseTotalModel {
  final String? warehouseName;
  final double totalBalance;

  const LegacyWarehouseTotalModel({
    this.warehouseName,
    required this.totalBalance,
  });

  factory LegacyWarehouseTotalModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LegacyWarehouseTotalModel(
      warehouseName: json['warehouseName']?.toString(),
      totalBalance: _numberValue(json['totalBalance']),
    );
  }
}

// تفاصيل اللوح الواحد
class LegacyBlockSlabModel {
  final String itemCode;
  final String? itemName;
  final double? x;
  final double? y;
  final double? z;
  final String? unitName;
  final List<LegacySlabBalanceModel> balances;

  const LegacyBlockSlabModel({
    required this.itemCode,
    this.itemName,
    this.x,
    this.y,
    this.z,
    this.unitName,
    required this.balances,
  });

  factory LegacyBlockSlabModel.fromJson(Map<String, dynamic> json) {
    final balancesJson = json['balances'] as List? ?? [];

    return LegacyBlockSlabModel(
      itemCode: json['itemCode']?.toString() ?? '',
      itemName: json['itemName']?.toString(),
      x: _nullableNumber(json['x']),
      y: _nullableNumber(json['y']),
      z: _nullableNumber(json['z']),
      unitName: json['unitName']?.toString(),
      balances: balancesJson.map((item) {
        return LegacySlabBalanceModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList(),
    );
  }
}

// رصيد اللوح في مستودع معين
class LegacySlabBalanceModel {
  final String? warehouseName;
  final double balance;

  const LegacySlabBalanceModel({
    this.warehouseName,
    required this.balance,
  });

  factory LegacySlabBalanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return LegacySlabBalanceModel(
      warehouseName: json['warehouseName']?.toString(),
      balance: _numberValue(json['balance']),
    );
  }
}

// تحويل القيم الرقمية بأمان
double _numberValue(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _nullableNumber(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int _intValue(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
