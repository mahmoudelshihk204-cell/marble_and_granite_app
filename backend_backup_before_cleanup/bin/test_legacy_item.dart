import 'package:backend/database/oracle_connection.dart';
import 'package:backend/repositories/legacy_item_repository.dart';
import 'package:backend/database/oracle_operation_queue.dart';

Future<void> main() async {
  final database = OracleDatabase();

  try {
    // فتح الاتصال بقاعدة بيانات Oracle.
    final connection = await database.connect();
    // إنشاء طابور خاص بالاختبار لتنظيم عمليات Oracle.
    final queue = OracleOperationQueue();
    // إنشاء Repository باستخدام الاتصال.
    final repository = LegacyItemRepository(
      connection: connection,
      queue: queue,
    );

    // اختبار استرجاع الصنف رقم 1500.
    final item = await repository.findByItemCode('1500');

    print('');
    print('========== LEGACY ITEM TEST ==========');

    if (item == null) {
      print('Item not found!');
    } else {
      print('Item Code: ${item.itemCode}');
      print('Item Name: ${item.itemName}');
      print('Alternate Code: ${item.alternateCode}');

      print('X: ${item.x}');
      print('Y: ${item.y}');
      print('Z: ${item.z}');

      print('Class: ${item.className}');
      print('Type: ${item.typeName}');
      print('Material: ${item.materialName}');
      print('Finish: ${item.finishName}');

      print('======================================');
    }
  } catch (error) {
    print('Legacy item test failed: $error');
  } finally {
    // إغلاق الاتصال حتى لو حصل خطأ.
    await database.close();
  }
}
