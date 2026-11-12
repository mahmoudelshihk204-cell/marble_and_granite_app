
import 'package:flutter/material.dart';

import '../models/legacy/legacy_block_model.dart';
import '../services/legacy/legacy_api_service.dart';

class BlockSearchPage extends StatefulWidget {
  const BlockSearchPage({super.key});

  @override
  State<BlockSearchPage> createState() => _BlockSearchPageState();
}

class _BlockSearchPageState extends State<BlockSearchPage> {
  final LegacyApiService api = LegacyApiService();

  // Controller لحقل البحث عن رقم البلوك
  final TextEditingController blockController = TextEditingController();

  LegacyBlockModel? block;

  bool isLoading = false;
  String? errorMessage;

  // البحث عن البلوك باستخدام رقمه
  Future<void> searchBlock() async {
    final blockNumber = blockController.text.trim();

    if (blockNumber.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a block number';
        block = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      block = null;
    });

    try {
      final result = await api.getBlockByNumber(blockNumber);

      if (!mounted) return;

      setState(() {
        block = result;
        isLoading = false;

        if (result == null) {
          errorMessage = 'Block not found';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    blockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xffC5A46D);

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
              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text('API Connection Successful'),
              subtitle: Text('Connected to Dart Server'),
            ),
          ),

          const SizedBox(height: 16),

          // حقل البحث عن رقم البلوك
          const Text(
            'Search Block',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: blockController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => searchBlock(),
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
                  onPressed: isLoading ? null : searchBlock,
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
                child: CircularProgressIndicator(
                  color: goldColor,
                ),
              ),
            ),

          // رسالة الخطأ أو عدم وجود البلوك
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
                    Expanded(
                      child: Text(errorMessage!),
                    ),
                  ],
                ),
              ),
            ),

          // نتائج البحث
          if (!isLoading && block != null) ...[
            _buildSummary(block!, goldColor),

            const SizedBox(height: 20),

            _buildWarehouseTotals(block!, goldColor),

            const SizedBox(height: 20),

            _buildSlabs(block!, goldColor),
          ],
        ],
      ),
    );
  }

  // ملخص البلوك
  Widget _buildSummary(
    LegacyBlockModel block,
    Color goldColor,
  ) {
    final summary = block.summary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Block Information',
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
                _infoRow(
                  'Block Number',
                  summary.blockNumber,
                ),

                const Divider(),

                _infoRow(
                  'Slab Count',
                  '${summary.slabCount}',
                ),

                const Divider(),

                _infoRow(
                  'Total Balance',
                  '${summary.totalBalance} m²',
                  valueColor: goldColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // إجمالي رصيد البلوك في كل مستودع
  Widget _buildWarehouseTotals(
    LegacyBlockModel block,
    Color goldColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Warehouse Totals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...block.warehouseTotals.map(
          (warehouse) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.warehouse,
                color: Color(0xffC5A46D),
              ),
              title: Text(
                warehouse.warehouseName ?? 'Warehouse',
              ),
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
  Widget _buildSlabs(
    LegacyBlockModel block,
    Color goldColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Slab Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...block.slabs.map(
          (slab) => Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              leading: const Icon(
                Icons.view_module,
                color: Color(0xffC5A46D),
              ),

              title: Text(
                'Slab ${slab.itemCode}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                slab.itemName ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              childrenPadding: const EdgeInsets.all(16),

              children: [
                _infoRow(
                  'Item Code',
                  slab.itemCode,
                ),

                _infoRow(
                  'Dimensions',
                  '${slab.x} × ${slab.y} × ${slab.z}',
                ),

                _infoRow(
                  'Unit',
                  slab.unitName ?? '-',
                ),

                const Divider(),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Warehouse Balances',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                ...slab.balances.map(
                  (balance) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.warehouse_outlined,
                      size: 20,
                    ),
                    title: Text(
                      balance.warehouseName ?? 'Warehouse',
                    ),
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
  Widget _infoRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
