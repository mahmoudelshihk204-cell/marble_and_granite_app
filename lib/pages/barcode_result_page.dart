// ignore_for_file: unused_import
import 'package:marble_and_granite/Widgets/legacy/item_information_card.dart';
import 'package:marble_and_granite/Widgets/legacy/raw_material_balance_section.dart';
import 'package:marble_and_granite/Widgets/legacy/warehouse_balances_section.dart';
import '../cubit/item_units_cubit/item_units_cubit.dart';
import '../cubit/item_units_cubit/item_units_state.dart';
import '../models/legacy/legacy_unit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_cubit.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_state.dart';
import '../cubit/item_code_search_cubit/item_code_search_cubit.dart';
import '../cubit/item_code_search_cubit/item_code_search_state.dart';
import '../cubit/item_balance_cubit/item_balance_cubit.dart';
import '../models/legacy/legacy_item_model.dart';
import '../repositories/block_repository.dart';

class BarcodeResultPage extends StatefulWidget {
  final String barcode;

  const BarcodeResultPage({super.key, required this.barcode});

  @override
  State<BarcodeResultPage> createState() => _BarcodeResultPageState();
}

class _BarcodeResultPageState extends State<BarcodeResultPage> {
  static const goldColor = Color(0xffC5A46D);

  late final ItemCodeSearchCubit cubit;
  late final ItemBalanceCubit balanceCubit;
  late final RawMaterialBalanceCubit rawMaterialBalanceCubit;
  late final ItemUnitsCubit unitsCubit;
  @override
  void initState() {
    super.initState();

    // استخدام نفس Repository المسجل في التطبيق.
    final repository = context.read<BlockRepository>();

    cubit = ItemCodeSearchCubit(repository);
    balanceCubit = ItemBalanceCubit(repository);
    rawMaterialBalanceCubit = RawMaterialBalanceCubit(repository);
    // بدء البحث عن الصنف بالباركود.
    cubit.searchBarcode(widget.barcode);
    // تحميل وحدات الصنف وأسعارها.
    unitsCubit = ItemUnitsCubit(repository);
  }

  @override
  void dispose() {
    cubit.close();
    balanceCubit.close();
    rawMaterialBalanceCubit.close();
    unitsCubit.close();
    super.dispose();
  }

  // فتح الكاميرا لمسح باركود جديد.
  Future<void> _scanAnotherBarcode() async {
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );

    if (!mounted || barcode == null || barcode.trim().isEmpty) {
      return;
    }

    // استبدال صفحة النتيجة الحالية بنتيجة الصنف الجديد.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeResultPage(barcode: barcode.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: balanceCubit),
        BlocProvider.value(value: rawMaterialBalanceCubit),
        BlocProvider.value(value: unitsCubit),
      ],
      child: BlocConsumer<ItemCodeSearchCubit, ItemCodeSearchState>(
        // عند نجاح البحث عن الصنف نبدأ تحميل أرصدته.
        listener: (context, state) async {
          if (state is ItemCodeSearchSuccess) {
            // أولاً: تحميل أرصدة المستودعات وانتظار انتهاء طلب Oracle.
            await balanceCubit.fetchBalances(state.item.itemCode);

            // ثانياً: بعد انتهاء الطلب الأول، نحمل إجمالي رصيد الخامة.
            await rawMaterialBalanceCubit.fetchBalance(state.item.itemCode);
            // تحميل وحدات الصنف وسعر المتر المربع.
            await unitsCubit.fetchUnits(state.item.itemCode);
          }
        },

        builder: (context, state) {
          final isLoading = state is ItemCodeSearchLoading;
          final item = state is ItemCodeSearchSuccess ? state.item : null;

          final errorMessage = state is ItemCodeSearchError
              ? state.message
              : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Barcode Result'),
              backgroundColor: Colors.black,
              foregroundColor: goldColor,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isLoading
                    ? const CircularProgressIndicator(color: goldColor)
                    : errorMessage != null
                    ? _buildError(errorMessage)
                    : item != null
                    ? _buildItemDetails(item)
                    : const Text('No data found'),
              ),
            ),
          );
        },
      ),
    );
  }

  // عرض رسالة الخطأ.
  Widget _buildError(String message) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.orange),
        title: Text(message),
      ),
    );
  }

  // عرض بيانات الصنف والباركود والوحدة والأبعاد والسعر.
  Widget _buildItemDetails(LegacyItemModel item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.qr_code_scanner, color: goldColor),
            title: Text('Barcode Search Result'),
            subtitle: Text('Item information from Oracle'),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Item Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        BlocBuilder<ItemUnitsCubit, ItemUnitsState>(
          builder: (context, state) {
            String unitName = 'Loading...';

            if (state is ItemUnitsSuccess) {
              // البحث عن وحدة المتر المربع.
              for (final unit in state.units) {
                if (unit.unitName?.trim() == 'م2') {
                  unitName = unit.unitName ?? '-';
                  break;
                }
              }

              if (unitName == 'Loading...') {
                unitName = 'Not available';
              }
            } else if (state is ItemUnitsError) {
              unitName = 'Not available';
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ItemInformationCard(item: item, barcode: widget.barcode),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        const RawMaterialBalanceSection(),

        const SizedBox(height: 16),

        const WarehouseBalancesSection(),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _scanAnotherBarcode,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text(
              'Scan Another Barcode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: goldColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}
