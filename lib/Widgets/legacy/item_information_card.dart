
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/item_units_cubit/item_units_cubit.dart';
import '../../cubit/item_units_cubit/item_units_state.dart';
import '../../models/legacy/legacy_item_model.dart';

class ItemInformationCard extends StatelessWidget {
  // بيانات الصنف القادمة من البحث.
  final LegacyItemModel item;

  // رقم الباركود اختياري؛ يظهر فقط في صفحة البحث بالباركود.
  final String? barcode;

  const ItemInformationCard({
    super.key,
    required this.item,
    this.barcode,
  });

  static const goldColor = Color(0xffC5A46D);

  // تنسيق الأرقام بمنزلتين عشريتين.
  String _formatNumber(double? value) {
    return (value ?? 0).toStringAsFixed(2);
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
              style: const TextStyle(fontWeight: FontWeight.w600),
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

        // نراقب حالة تحميل وحدات الصنف وسعر المتر المربع.
        BlocBuilder<ItemUnitsCubit, ItemUnitsState>(
          builder: (context, state) {
            String unitName = 'Loading...';
            String price = 'Loading...';

            if (state is ItemUnitsSuccess) {
              // نبحث عن وحدة المتر المربع.
              for (final unit in state.units) {
                if (unit.unitName?.trim() == 'م2') {
                  unitName = unit.unitName ?? '-';

                  price = unit.salePrice == null
                      ? 'Not available'
                      : '${_formatNumber(unit.salePrice)} ج.م / م²';

                  break;
                }
              }

              // لو الوحدة غير موجودة في البيانات.
              if (unitName == 'Loading...') {
                unitName = 'Not available';
                price = 'Not available';
              }
            } else if (state is ItemUnitsError) {
              unitName = 'Not available';
              price = 'Not available';
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // يظهر صف الباركود فقط عند تمرير قيمته.
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

                    _infoRow('Unit', unitName),
                    const Divider(),

                    // الأبعاد كما اتفقنا: الوحدة المعروضة م2.
                    _infoRow(
                      'Dimensions',
                      '${_formatNumber(item.x)} × '
                      '${_formatNumber(item.y)} × '
                      '${_formatNumber(item.z)} م2',
                    ),
                    const Divider(),

                    // سعر وحدة المتر المربع.
                    _infoRow('Price / م²', price),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
