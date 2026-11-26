import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marble_and_granite/Widgets/legacy/item_information_card.dart';
import 'package:marble_and_granite/Widgets/legacy/raw_material_balance_section.dart';
import 'package:marble_and_granite/Widgets/legacy/warehouse_balances_section.dart';
import 'package:marble_and_granite/models/legacy/legacy_unit_model.dart';
import '../cubit/item_units_cubit/item_units_cubit.dart';
import '../cubit/item_units_cubit/item_units_state.dart';
import '../cubit/item_code_search_cubit/item_code_search_cubit.dart';
import '../cubit/item_code_search_cubit/item_code_search_state.dart';
import '../models/legacy/legacy_item_model.dart';
import '../repositories/block_repository.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_cubit.dart';
import '../cubit/item_balance_cubit/item_balance_cubit.dart';

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
  late final ItemUnitsCubit unitsCubit;
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
    // إنشاء Cubit المسؤول عن تحميل وحدات الصنف.
    unitsCubit = ItemUnitsCubit(repository);
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
    unitsCubit.close();
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
      //  BlocProvider.value(value: balanceCubit),
      //  BlocProvider.value(value: rawMaterialBalanceCubit),
       // BlocProvider.value(value: unitsCubit),
      ],
      child: BlocConsumer<ItemCodeSearchCubit, ItemCodeSearchState>(
        listener: (context, state) async {
          if (state is ItemCodeSearchSuccess) {
            // تحميل أرصدة المخازن.
           // await balanceCubit.fetchBalances(state.item.itemCode);

            // تحميل رصيد الخامة.
          //  await rawMaterialBalanceCubit.fetchBalance(state.item.itemCode);

            // تحميل وحدات الصنف.
           // await unitsCubit.fetchUnits(state.item.itemCode);
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

                if (!isLoading && item != null) ItemInformationCard(item: item),

                if (!isLoading && item != null) ...[
                  const SizedBox(height: 16),

                  // عرض أرصدة كل المستودعات.
                  WarehouseBalancesSection(balances: item.warehouseBalances),

                  const SizedBox(height: 16),

                  // عرض إجمالي رصيد الخامة.
                  const RawMaterialBalanceSection(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
