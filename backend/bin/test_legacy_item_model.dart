
import 'package:backend/models/legacy_item_model.dart';

void main() {
  print('========== MODEL TEST ==========');

  // الاختبار الأول: بيانات صنف صحيحة.
  final item = LegacyItemModel.fromMap({
    'ITEM_CODE': 1500,
    'ITEM_NAME': 'Test Item',
    'ITEM_CODE2': '43314',
    'X': 1.43,
    'Y': 0.64,
    'Z': 2,
  });

  print('Valid Item Code: ${item.itemCode}');
  print('Item Name: ${item.itemName}');
  print('Alternate Code: ${item.alternateCode}');

  // الاختبار الثاني: بيانات ناقصها ITEM_CODE.
  try {
    LegacyItemModel.fromMap({
      'ITEM_NAME': 'Invalid Item',
    });

    print('ERROR: Missing ITEM_CODE was accepted!');
  } on FormatException catch (error) {
    print('Missing Code Test: PASSED');
    print('Error: ${error.message}');
  }

  print('========== TEST FINISHED ==========');
}
