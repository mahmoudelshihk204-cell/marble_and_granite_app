import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/item_code_search_cubit/item_code_search_cubit.dart';
import '../cubit/item_code_search_cubit/item_code_search_state.dart';
import '../models/legacy/legacy_item_model.dart';
import '../repositories/block_repository.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_cubit.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_state.dart';
import '../cubit/item_balance_cubit/item_balance_cubit.dart';
import '../cubit/item_balance_cubit/item_balance_state.dart';

class ItemCodeSearchPage extends StatefulWidget {
  // استقبال Barcode اختياري من صفحة الكاميرا.
  final String? initialBarcode;

  const ItemCodeSearchPage({super.key, this.initialBarcode});

  @override
  State<ItemCodeSearchPage> createState() => _ItemCodeSearchPageState();
}

class _ItemCodeSearchPageState extends State<ItemCodeSearchPage> {
  static const goldColor = Color(0xffC5A46D);

  late final ItemCodeSearchCubit cubit;
  late final RawMaterialBalanceCubit rawMaterialBalanceCubit;
  late final ItemBalanceCubit balanceCubit;

  // Controller لاستقبال Item Code عند البحث اليدوي.
  final TextEditingController itemCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // استخدام Repository المسجل في main.dart.
    final repository = context.read<BlockRepository>();
    // إنشاء Cubit المسؤول عن جلب رصيد الخامات.
    rawMaterialBalanceCubit = RawMaterialBalanceCubit(repository);
    // إنشاء Cubit المسؤول عن تحميل أرصدة المستودعات.
    balanceCubit = ItemBalanceCubit(repository);
    cubit = ItemCodeSearchCubit(repository);

    // لو الصفحة استقبلت Barcode من الكاميرا، نبدأ البحث تلقائياً.
    final barcode = widget.initialBarcode?.trim();

    if (barcode != null && barcode.isNotEmpty) {
      cubit.searchBarcode(barcode);
    }
  }

  @override
  void dispose() {
    itemCodeController.dispose();
    cubit.close();
    rawMaterialBalanceCubit.close();
    balanceCubit.close();
    super.dispose();
  }

  // البحث اليدوي باستخدام Item Code.
  void _searchItemCode() {
    cubit.searchItemCode(itemCodeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: balanceCubit),
        BlocProvider.value(value: rawMaterialBalanceCubit),
      ],
      child: BlocConsumer<ItemCodeSearchCubit, ItemCodeSearchState>(
        listener: (context, state) async {
          if (state is ItemCodeSearchSuccess) {
            // أولاً: تحميل أرصدة المستودعات وانتظار انتهاء الطلب.
            await balanceCubit.fetchBalances(state.item.itemCode);

            // ثانياً: تحميل إجمالي رصيد الخامة.
            await rawMaterialBalanceCubit.fetchBalance(state.item.itemCode);
          }
        },
        builder: (context, state) {
          final isLoading = state is ItemCodeSearchLoading;

          final errorMessage = state is ItemCodeSearchError
              ? state.message
              : null;

          final item = state is ItemCodeSearchSuccess ? state.item : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Search Item Code'),
              backgroundColor: Colors.black,
              foregroundColor: goldColor,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.inventory_2, color: goldColor),
                    title: Text('Item Search'),
                    subtitle: Text('Search Oracle inventory items'),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Enter Item Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: itemCodeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchItemCode(),
                        decoration: const InputDecoration(
                          labelText: 'Item Code',
                          hintText: 'Enter item code',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _searchItemCode,
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

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: goldColor),
                    ),
                  ),

                if (!isLoading && errorMessage != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.error_outline,
                        color: Colors.orange,
                      ),
                      title: Text(errorMessage),
                    ),
                  ),

                if (!isLoading && item != null) _buildItemDetails(item),

                if (!isLoading && item != null) ...[
                  const SizedBox(height: 16),

                  // عرض أرصدة كل المستودعات.
                  _buildBalancesSection(),

                  const SizedBox(height: 16),

                  // عرض إجمالي رصيد الخامة.
                  _buildRawMaterialBalanceSection(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // عرض بيانات الصنف القادمة من Oracle.
  Widget _buildItemDetails(LegacyItemModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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

                _infoRow(
                  'Dimensions',
                  '${item.x ?? '-'} × ${item.y ?? '-'} × ${item.z ?? '-'}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // عرض إجمالي رصيد الخامات.
  Widget _buildRawMaterialBalanceSection() {
    return BlocBuilder<RawMaterialBalanceCubit, RawMaterialBalanceState>(
      builder: (context, state) {
        if (state is RawMaterialBalanceLoading ||
            state is RawMaterialBalanceInitial) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(color: goldColor),
              title: Text('Loading raw material balance...'),
            ),
          );
        }

        if (state is RawMaterialBalanceError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.orange),
              title: const Text('Failed to load raw material balance'),
              subtitle: Text(state.message),
            ),
          );
        }

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

  // عرض أرصدة الصنف في جميع المستودعات.
  Widget _buildBalancesSection() {
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

  // تنسيق الأرقام بمنزلتين عشريتين.
  String _formatNumber(double? value) {
    return (value ?? 0).toStringAsFixed(2);
  }

  // Widget مشترك لعرض اسم الخاصية وقيمتها.
  Widget _infoRow(String title, String value) {
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
