import 'dart:io';
import 'package:excel_ce/excel_ce.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExportService {
  // تصدير الأكواد وأعداد مرات المسح إلى ملف Excel
  static Future<void> exportAndShare(
    Map<String, int> scannedItems,
  ) async {
    // إنشاء ملف Excel جديد
    final excel = Excel.createExcel();

    // استخدام الشيت الافتراضي
    final sheet = excel['Sheet1'];

    // إضافة عناوين الأعمدة المطلوبة فقط
    sheet.appendRow([
      TextCellValue('Item Code'),
      TextCellValue('Scan Count'),
    ]);

    // إضافة كل كود وعدد مرات تسجيله
    scannedItems.forEach((itemCode, scanCount) {
      sheet.appendRow([
        TextCellValue(itemCode),
        IntCellValue(scanCount),
      ]);
    });

    // تحويل ملف Excel إلى bytes
    final fileBytes = excel.save();

    if (fileBytes == null) {
      throw Exception('Failed to generate Excel file');
    }

    // تحديد مكان مؤقت لحفظ الملف على الجهاز
    final directory = await getTemporaryDirectory();

    // اسم مميز للملف باستخدام الوقت الحالي
    final fileName =
        'offline_scan_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    final file = File('${directory.path}/$fileName');

    // حفظ بيانات Excel في الملف
    await file.writeAsBytes(fileBytes, flush: true);

    // فتح نافذة المشاركة لإرسال الملف أو حفظه
    await SharePlus.instance.share(
      ShareParams(
        title: 'Offline Scan Report',
        files: [
          XFile(file.path),
        ],
      ),
    );
  }
}
