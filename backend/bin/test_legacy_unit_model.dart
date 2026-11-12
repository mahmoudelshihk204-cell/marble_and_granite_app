
import 'package:backend/models/legacy_unit_model.dart';

void main() {
  print('========== UNIT MODEL TEST ==========');

  // الاختبار الأول: بيانات وحدة صحيحة.
  final unit = LegacyUnitModel.fromMap({
    'ITEM_CODE': 1500,
    'UNIT_CODE': 1,
    'UNIT_NAME': 'م2',
    'UNIT_NAME2': '-',
    'COST_PRICE': 1,
    'WHOL_PRICE': 0,
    'SALE_PRICE': 2800,
    'AVR_COST': 1,
    'UNIT_MASTER': 1,
    'BAL_UNIT_CODE': 0,
    'CONV_VAL': 0,
    'UNIT_VAL': 1,
  });

  print('Item Code: ${unit.itemCode}');
  print('Unit Code: ${unit.unitCode}');
  print('Unit Name: ${unit.unitName}');
  print('Sale Price: ${unit.salePrice}');
  print('Is Master Unit: ${unit.isMasterUnit}');

  // الاختبار الثاني: التأكد من تحويل 1 إلى true.
  if (unit.isMasterUnit == true) {
    print('Boolean Conversion Test: PASSED');
  } else {
    print('Boolean Conversion Test: FAILED');
  }

  // الاختبار الثالث: التأكد من رفض غياب ITEM_CODE.
  try {
    LegacyUnitModel.fromMap({
      'UNIT_CODE': 1,
    });
    print('Missing ITEM_CODE Test: FAILED');
  } on FormatException {
    print('Missing ITEM_CODE Test: PASSED');
  }

  // الاختبار الرابع: التأكد من رفض غياب UNIT_CODE.
  try {
    LegacyUnitModel.fromMap({
      'ITEM_CODE': 1500,
    });
    print('Missing UNIT_CODE Test: FAILED');
  } on FormatException {
    print('Missing UNIT_CODE Test: PASSED');
  }

  print('========== TEST FINISHED ==========');
}
