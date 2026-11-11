
// بيانات رصيد صنف معين داخل مخزن معين.
class LegacyBalanceModel {
  final String itemCode;
  final String branchCode;
  final String? branchName;

  // قيم الأرصدة والحركة من قاعدة البيانات
  final num? balance;
  final num? negativeBalance;
  final num? rais;
  final num? reDem;

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

  static String? _stringValue(Object? value) {
    return value?.toString();
  }

  static num? _numberValue(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }

  static DateTime? _dateValue(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  factory LegacyBalanceModel.fromMap(Map<String, dynamic> map) {
    return LegacyBalanceModel(
      itemCode: map['ITEM_CODE'].toString(),
      branchCode: map['BRAN_CODE'].toString(),
      branchName: _stringValue(map['BRANCH_NAME']),
      balance: _numberValue(map['BAL']),
      negativeBalance: _numberValue(map['NBAL']),
      rais: _numberValue(map['RAIS']),
      reDem: _numberValue(map['RE_DEM']),
      systemDate: _dateValue(map['SYS_DATE']),
    );
  }

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
