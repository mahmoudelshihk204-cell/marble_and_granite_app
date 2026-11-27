import 'package:flutter/material.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';
import 'package:marble_and_granite/services/excel_export_service.dart';

class OfflineModePage extends StatefulWidget {
  const OfflineModePage({super.key});

  @override
  State<OfflineModePage> createState() => _OfflineModePageState();
}

class _OfflineModePageState extends State<OfflineModePage> {
  // كل كود صنف مرتبط بعدد مرات تسجيله.
  final Map<String, int> _scannedItems = {};

  // إجمالي عدد مرات الـ Scan، بما فيها الأكواد المتكررة.
  int get _totalScans =>
      _scannedItems.values.fold(0, (sum, count) => sum + count);

  // إضافة كود للقائمة أو زيادة عداده لو موجود بالفعل.
  void _addCode(String code) {
    final normalizedCode = code.trim();

    if (normalizedCode.isEmpty) return;

    setState(() {
      _scannedItems.update(
        normalizedCode,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    });
  }

  // فتح الكاميرا واستقبال الكود المقروء.
  Future<void> _scanCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const ScannerPage(),
      ),
    );

    if (!mounted || result == null) return;

    _addCode(result);
  }

  // إدخال كود الصنف يدويًا.
  
Future<void> _manualEntry() async {
  // هنحتفظ بالكود المكتوب هنا من غير TextEditingController.
  String enteredCode = '';

  final code = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Enter Item Code'),
        content: TextField(
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: 'Enter barcode or item code',
            border: OutlineInputBorder(),
          ),

          // تخزين الكود أثناء الكتابة.
          onChanged: (value) {
            enteredCode = value;
          },

          // إضافة الكود عند الضغط على Enter.
          onSubmitted: (value) {
            Navigator.pop(dialogContext, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, enteredCode);
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );

  if (!mounted || code == null || code.trim().isEmpty) return;

  // إضافة الكود للقائمة وزيادة عداده لو موجود.
  _addCode(code);
}
// تصدير الأكواد وأعداد مرات تسجيلها إلى ملف Excel.
Future<void> _exportToExcel() async {
  // منع التصدير لو القائمة فاضية.
  if (_scannedItems.isEmpty) return;

  try {
    // إرسال نسخة من البيانات لخدمة Excel.
    await ExcelExportService.exportAndShare(
      Map<String, int>.from(_scannedItems),
    );
  } catch (e) {
    // عرض رسالة الخطأ لو حصلت مشكلة أثناء إنشاء الملف.
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Excel export failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // مسح جميع الأكواد بعد تأكيد المستخدم.
  Future<void> _clearAll() async {
    if (_scannedItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Codes?'),
          content: const Text(
            'Are you sure you want to delete all scanned items?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() {
        _scannedItems.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xffC5A46D);

    return Scaffold(
      backgroundColor: const Color(0xff151515),
      appBar: AppBar(
        title: const Text(
          'Offline Mode',
          style: TextStyle(
            color: gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: .5),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // أزرار الـ Scan والإدخال اليدوي.
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      title: 'Scan Code',
                      icon: Icons.qr_code_scanner,
                      color: gold,
                      onPressed: _scanCode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionButton(
                      title: 'Manual Entry',
                      icon: Icons.keyboard,
                      color: Colors.blueGrey,
                      onPressed: _manualEntry,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ملخص عدد الأكواد وعدد مرات تسجيلها.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: gold.withValues(alpha: .5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _counter('Unique Items', _scannedItems.length),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white24,
                    ),
                    _counter('Total Scans', _totalScans),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // عنوان القائمة.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scanned Items',
                    style: TextStyle(
                      color: gold,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Clear All',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // عرض الأكواد وعدد مرات تسجيل كل كود.
              Expanded(
                child: _scannedItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 65,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No scanned items yet',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _scannedItems.length,
                        itemBuilder: (context, index) {
                          final code =
                              _scannedItems.keys.elementAt(index);
                          final count = _scannedItems[code]!;

                          return Card(
                            color: const Color(0xff252525),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: gold,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                code,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: gold.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Scans: $count',
                                  style: const TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 12),

              // زر التصدير هنفعّله في المرحلة التالية.
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                 onPressed: _scannedItems.isEmpty ? null : _exportToExcel,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export to Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade800,
                    disabledForegroundColor: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم موحد لأزرار الشاشة.
  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 95,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // عرض العداد.
  Widget _counter(String title, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Color(0xffC5A46D),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
