
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/item_balance_cubit/item_balance_cubit.dart';
import '../../cubit/item_balance_cubit/item_balance_state.dart';

class WarehouseBalancesSection extends StatelessWidget {
  const WarehouseBalancesSection({super.key});

  static const goldColor = Color(0xffC5A46D);

  // تنسيق الأرقام بمنزلتين عشريتين.
  String _formatNumber(double? value) {
    return (value ?? 0).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemBalanceCubit, ItemBalanceState>(
      builder: (context, state) {
        // أثناء تحميل الأرصدة.
        if (state is ItemBalanceLoading ||
            state is ItemBalanceInitial) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(color: goldColor),
              title: Text('Loading warehouse balances...'),
            ),
          );
        }

        // في حالة حدوث خطأ.
        if (state is ItemBalanceError) {
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.error_outline,
                color: Colors.orange,
              ),
              title: const Text('Failed to load balances'),
              subtitle: Text(state.message),
            ),
          );
        }

        // عند نجاح تحميل الأرصدة.
        if (state is ItemBalanceSuccess) {
          final balances = state.balances;

          // لو الصنف ملوش أرصدة في المستودعات.
          if (balances.isEmpty) {
            return const Card(
              child: ListTile(
                leading: Icon(Icons.warehouse_outlined),
                title: Text('No warehouse balances found'),
              ),
            );
          }

          // حساب إجمالي الرصيد في كل المستودعات.
          final totalBalance = balances.fold<double>(
            0,
            (total, balance) => total + (balance.balance ?? 0),
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

                  // عرض رصيد كل مستودع.
                  ...balances.map((balance) {
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            balance.branchName ??
                                'Warehouse ${balance.branchCode}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            _formatNumber(balance.balance),
                            style: const TextStyle(
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

                  // إجمالي أرصدة جميع المستودعات.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Balance',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Text(
                        _formatNumber(totalBalance),
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

        return const SizedBox.shrink();
      },
    );
  }
}
