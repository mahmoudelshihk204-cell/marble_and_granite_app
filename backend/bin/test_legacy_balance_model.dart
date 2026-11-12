
import 'package:backend/models/legacy_balance_model.dart';

void main() {
  print('========== BALANCE MODEL TEST ==========');

  // الاختبار الأول: رصيد صحيح وقيمته صفر.
  final balance = LegacyBalanceModel.fromMap({
    'ITEM_CODE': 1500,
    'BRAN_CODE': 1001001001,
    'BRANCH_NAME': 'مستودع - 1 - اونكس - بدر',
    'BAL': 0,
    'NBAL': 0,
    'RAIS': 0,
    'RE_DEM': 0,
  });

  print('Item Code: ${balance.itemCode}');
  print('Branch Code: ${balance.branchCode}');
  print('Branch Name: ${balance.branchName}');
  print('Balance: ${balance.balance}');

  // نتأكد إن الصفر محفوظ زي ما هو.
  if (balance.balance == 0) {
    print('Zero Balance Test: PASSED');
  } else {
    print('Zero Balance Test: FAILED');
  }

  // الاختبار الثاني: غياب ITEM_CODE.
  try {
    LegacyBalanceModel.fromMap({
      'BRAN_CODE': 1001001001,
    });
    print('Missing ITEM_CODE Test: FAILED');
  } on FormatException {
    print('Missing ITEM_CODE Test: PASSED');
  }

  // الاختبار الثالث: غياب BRAN_CODE.
  try {
    LegacyBalanceModel.fromMap({
      'ITEM_CODE': 1500,
    });
    print('Missing BRAN_CODE Test: FAILED');
  } on FormatException {
    print('Missing BRAN_CODE Test: PASSED');
  }

  print('========== TEST FINISHED ==========');
}
