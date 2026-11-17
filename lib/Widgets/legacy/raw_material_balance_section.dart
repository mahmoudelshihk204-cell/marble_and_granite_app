
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/raw_material_balance_cubit/raw_material_balance_cubit.dart';
import '../../cubit/raw_material_balance_cubit/raw_material_balance_state.dart';

class RawMaterialBalanceSection extends StatelessWidget {
  const RawMaterialBalanceSection({super.key});

  static const goldColor = Color(0xffC5A46D);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RawMaterialBalanceCubit, RawMaterialBalanceState>(
      builder: (context, state) {
        // أثناء تحميل رصيد الخامة.
        if (state is RawMaterialBalanceLoading ||
            state is RawMaterialBalanceInitial) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(color: goldColor),
              title: Text('Loading raw material balance...'),
            ),
          );
        }

        // في حالة حدوث خطأ.
        if (state is RawMaterialBalanceError) {
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.error_outline,
                color: Colors.orange,
              ),
              title: const Text('Failed to load raw material balance'),
              subtitle: Text(state.message),
            ),
          );
        }

        // عند نجاح تحميل رصيد الخامة.
        if (state is RawMaterialBalanceSuccess) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    color: goldColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Raw Material Balance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Text(
                    state.balance.toStringAsFixed(3),
                    style: const TextStyle(
                      color: goldColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
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
