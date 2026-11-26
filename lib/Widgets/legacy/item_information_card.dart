
import 'package:flutter/material.dart';

import '../../models/legacy/legacy_item_model.dart';

class ItemInformationCard extends StatelessWidget {
  // بيانات الصنف القادمة من البحث.
  final LegacyItemModel item;

  // رقم الباركود اختياري.
  final String? barcode;

  const ItemInformationCard({
    super.key,
    required this.item,
    this.barcode,
  });

  static const goldColor = Color(0xffC5A46D);

  // تنسيق الأرقام بمنزلتين عشريتين.
  String _formatNumber(double? value) {
    if (value == null) return '-';
    return value.toStringAsFixed(2);
  }

  // تنسيق السعر.
  String _formatPrice(double? value) {
    if (value == null) return 'Not available';
    return '${_formatNumber(value)} ج.م / م²';
  }

  // Widget موحد لعرض اسم الخاصية وقيمتها.
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // قراءة الوحدة والسعر مباشرة من نتيجة Barcode API.
    final unitName = item.unitName?.trim().isNotEmpty == true
        ? item.unitName!
        : 'Not available';

    final price = _formatPrice(item.price);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // إظهار الباركود عند البحث بالكاميرا.
                if (barcode != null) ...[
                  _infoRow('Barcode', barcode!),
                  const Divider(),
                ],

                _infoRow('Item Code', item.itemCode),
                const Divider(),

                _infoRow('Item Name', item.itemName),
                const Divider(),

                _infoRow('Block Number', item.alternateCode ?? '-'),
                const Divider(),

                _infoRow('Class', item.className ?? '-'),
                const Divider(),

                _infoRow('Type', item.typeName ?? '-'),
                const Divider(),

                _infoRow('Material', item.materialName ?? '-'),
                const Divider(),

                _infoRow('Finish', item.finishName ?? '-'),
                const Divider(),

                _infoRow('Color Code', item.colorCode ?? '-'),
                const Divider(),

                // الوحدة القادمة مباشرة من TopSoftware.
                _infoRow('Unit', unitName),
                const Divider(),

                // كود الوحدة للمراجعة عند الحاجة.
                _infoRow('Unit Code', item.unitCode ?? '-'),
                const Divider(),

                // عرض الأبعاد.
                _infoRow(
                  'Dimensions',
                  '${_formatNumber(item.x)} × '
                  '${_formatNumber(item.y)} × '
                  '${_formatNumber(item.z)} م',
                ),
                const Divider(),

                // السعر القادم من Barcode API.
                _infoRow('Price / م²', price),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
