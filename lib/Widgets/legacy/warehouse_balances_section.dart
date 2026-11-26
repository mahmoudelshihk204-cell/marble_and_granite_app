
import 'package:flutter/material.dart';
import '../../models/legacy/barcode_warehouse_balance_model.dart';

class WarehouseBalancesSection extends StatelessWidget {
  final List<BarcodeWarehouseBalanceModel> balances;

  const WarehouseBalancesSection({
    super.key,
    required this.balances,
  });

  static const goldColor = Color(0xffC5A46D);

  String _formatNumber(double? value) {
    return (value ?? 0).toStringAsFixed(3);
  }

  // عرض عدد القطع بدون أصفار عشرية غير ضرورية.
  String _formatCount(double? value) {
    if (value == null) return '-';

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.warehouse_outlined),
          title: Text('No warehouse balances found'),
        ),
      );
    }

    // إجمالي الكمية في كل المستودعات.
    final totalAmount = balances.fold<double>(
      0,
      (total, item) => total + (item.amount ?? 0),
    );

    // إجمالي عدد القطع.
    final totalCount = balances.fold<double>(
      0,
      (total, item) => total + (item.itemCount ?? 0),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warehouse, color: goldColor),
                SizedBox(width: 10),
                Text(
                  'Warehouse Balances',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            ...balances.map((balance) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      balance.warehouseName ??
                          'Warehouse ${balance.warehouseCode ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Item Count: ${_formatCount(balance.itemCount)}',
                    ),
                    trailing: Text(
                      _formatNumber(balance.amount),
                      style: const TextStyle(
                        color: goldColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            }),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Total Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  _formatNumber(totalAmount),
                  style: const TextStyle(
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Total Item Count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  _formatCount(totalCount),
                  style: const TextStyle(
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
