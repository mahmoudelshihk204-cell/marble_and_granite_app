// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marble_and_granite/repositories/block_repository.dart';

import '../cubit/block_search_cubit/block_search_cubit.dart';
import '../cubit/block_search_cubit/block_search_state.dart';
import '../models/legacy/legacy_block_model.dart';

class BlockSearchPage extends StatefulWidget {
  const BlockSearchPage({super.key});

  @override
  State<BlockSearchPage> createState() => _BlockSearchPageState();
}

class _BlockSearchPageState extends State<BlockSearchPage> {
  // إنشاء Cubit واحد لإدارة البحث طوال فترة وجود الشاشة
  late final BlockSearchCubit cubit;

  // Controller لقراءة رقم البلوك من المستخدم
  final TextEditingController blockController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // الحصول على Repository الذي تم إنشاؤه في main.dart
    final blockRepository = context.read<BlockRepository>();

    // إنشاء Cubit باستخدام Repository المركزي
    cubit = BlockSearchCubit(blockRepository);
  }

  @override
  void dispose() {
    blockController.dispose();
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xffC5A46D);

    return BlocProvider.value(
      value: cubit,

      child: BlocBuilder<BlockSearchCubit, BlockSearchState>(
        builder: (context, state) {
          // تحديد حالة الشاشة بناءً على الحالة الصادرة من Cubit
          final isLoading = state is BlockSearchLoading;

          final errorMessage = state is BlockSearchError ? state.message : null;

          final block = state is BlockSearchSuccess ? state.block : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Block Search'),
              backgroundColor: Colors.black,
              foregroundColor: goldColor,
            ),

            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // حالة الاتصال بالسيرفر
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('API Connection Successful'),
                    subtitle: Text('Connected to Dart Server'),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Search Block',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: blockController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) {
                          context.read<BlockSearchCubit>().searchBlock(
                            blockController.text,
                          );
                        },
                        decoration: const InputDecoration(
                          labelText: 'Block Number',
                          hintText: 'Enter block number',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context.read<BlockSearchCubit>().searchBlock(
                                  blockController.text,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldColor,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // مؤشر التحميل
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(color: goldColor),
                    ),
                  ),

                // رسالة الخطأ
                if (!isLoading && errorMessage != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(errorMessage)),
                        ],
                      ),
                    ),
                  ),

                // عرض نتائج البحث
                if (!isLoading && block != null) ...[
                  _buildSummary(block, goldColor),

                  const SizedBox(height: 20),

                  _buildWarehouseTotals(block, goldColor),

                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ملخص البلوك

  // ملخص البلوك ومعلومات الأبعاد والوحدة
  Widget _buildSummary(LegacyBlockModel block, Color goldColor) {
    final summary = block.summary;

    // استخراج الأبعاد المختلفة الموجودة في بيانات البلوك.
    final dimensions = block.slabs
        .map((slab) => '${slab.x ?? '-'} × ${slab.y ?? '-'} × ${slab.z ?? '-'}')
        .toSet()
        .join(' ، ');

    // استخراج الوحدات المختلفة.
    final units = block.slabs
        .map((slab) => slab.unitName)
        .where((unit) => unit != null && unit.isNotEmpty)
        .toSet()
        .join(' ، ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Block Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow('Block Number', summary.blockNumber),

               
                const Divider(),

                _infoRow('Item Code', summary.itemCode),

                const Divider(),

                _infoRow('Item Name', summary.itemName),
                const Divider(),
                _infoRow('الفرز', '${summary.slabCount}'),

                const Divider(),

                _infoRow('Dimensions', dimensions.isEmpty ? '-' : dimensions),

                const Divider(),

                _infoRow('Unit', units.isEmpty ? '-' : units),

                const Divider(),

                _infoRow(
                  'Total Balance',
                  '${summary.totalBalance} m²',
                  valueColor: goldColor,
                ),
                const Divider(),

                _infoRow('Quantity', '${summary.quantity}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // إجمالي رصيد البلوك في كل مستودع
  Widget _buildWarehouseTotals(LegacyBlockModel block, Color goldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warehouse Totals',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...block.warehouseTotals.map(
          (warehouse) => Card(
            child: ListTile(
              leading: const Icon(Icons.warehouse, color: Color(0xffC5A46D)),
              title: Text(warehouse.warehouseName ?? 'Warehouse'),
              trailing: Text(
                '${warehouse.totalBalance}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: goldColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // تفاصيل الألواح وأرصدة كل لوح
  Widget _buildSlabs(LegacyBlockModel block, Color goldColor) {
    for (final slab in block.slabs) {
      debugPrint(
        'DIMENSIONS DEBUG: '
        'Code=${slab.itemCode}, '
        'X=${slab.x}, Y=${slab.y}, Z=${slab.z}',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Slab Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        ...block.slabs.map(
          (slab) => Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: const Icon(Icons.view_module, color: Color(0xffC5A46D)),

              title: Text(
                'Slab ${slab.itemCode}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Text(
                slab.itemName ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              childrenPadding: const EdgeInsets.all(16),

              children: [
                _infoRow('Item Code', slab.itemCode),

                _infoRow('Dimensions', '${slab.x} × ${slab.y} × ${slab.z}'),

                _infoRow('Unit', slab.unitName ?? '-'),

                const Divider(),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Warehouse Balances',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 8),

                ...slab.balances.map(
                  (balance) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.warehouse_outlined, size: 20),
                    title: Text(balance.warehouseName ?? 'Warehouse'),
                    trailing: Text(
                      '${balance.balance}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: goldColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // صف موحد لعرض اسم الحقل والقيمة
  Widget _infoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
