
class LegacyBalanceModel {
  // كود الصنف وكود المخزن
  final String itemCode;
  final String branchCode;

  // اسم المخزن
  final String? branchName;

  // بيانات الرصيد
  final double? balance;
  final double? negativeBalance;
  final double? rais;
  final double? reDem;

  // تاريخ آخر تحديث
  final DateTime? systemDate;

  const LegacyBalanceModel({
    required this.itemCode,
    required this.branchCode,
    this.branchName,
    this.balance,
    this.negativeBalance,
    this.rais,
    this.reDem,
    this.systemDate,
  });

  // تحويل بيانات JSON إلى Dart Object
  factory LegacyBalanceModel.fromJson(Map<String, dynamic> json) {
    if (json['itemCode'] == null) {
      throw const FormatException('itemCode is missing');
    }

    if (json['branchCode'] == null) {
      throw const FormatException('branchCode is missing');
    }

    return LegacyBalanceModel(
      itemCode: json['itemCode'].toString(),
      branchCode: json['branchCode'].toString(),
      branchName: _stringValue(json['branchName']),
      balance: _numberValue(json['balance']),
      negativeBalance: _numberValue(json['negativeBalance']),
      rais: _numberValue(json['rais']),
      reDem: _numberValue(json['reDem']),
      systemDate: _dateValue(json['systemDate']),
    );
  }

  // تحويل القيم إلى String مع السماح بـ null
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

  // تحويل التاريخ
  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  // تحويل Dart Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'branchCode': branchCode,
      'branchName': branchName,
      'balance': balance,
      'negativeBalance': negativeBalance,
      'rais': rais,
      'reDem': reDem,
      'systemDate': systemDate?.toIso8601String(),
    };
  }
}
