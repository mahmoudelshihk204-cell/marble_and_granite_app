// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_cubit.dart';
import '../cubit/raw_material_balance_cubit/raw_material_balance_state.dart';
import '../cubit/item_code_search_cubit/item_code_search_cubit.dart';
import '../cubit/item_code_search_cubit/item_code_search_state.dart';
import '../cubit/item_balance_cubit/item_balance_cubit.dart';
import '../cubit/item_balance_cubit/item_balance_state.dart';
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
  }

  @override
  void dispose() {
    cubit.close();
    balanceCubit.close();
    rawMaterialBalanceCubit.close();
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
      ],
      child: BlocConsumer<ItemCodeSearchCubit, ItemCodeSearchState>(
        // عند نجاح البحث عن الصنف نبدأ تحميل أرصدته.
        listener: (context, state) async {
          if (state is ItemCodeSearchSuccess) {
            // أولاً: تحميل أرصدة المستودعات وانتظار انتهاء طلب Oracle.
            await balanceCubit.fetchBalances(state.item.itemCode);

            // ثانياً: بعد انتهاء الطلب الأول، نحمل إجمالي رصيد الخامة.
            await rawMaterialBalanceCubit.fetchBalance(state.item.itemCode);
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

  // عرض بيانات الصنف والأرصدة.
  Widget _buildItemDetails(LegacyItemModel item) {
    return ListView(
      children: [
        const Card(
          child: ListTile(
            leading: Icon(Icons.qr_code_scanner, color: goldColor),
            title: Text('Barcode Search Result'),
            subtitle: Text('Item information from Oracle'),
          ),
        ),

        const SizedBox(height: 16),

        // بيانات الصنف الأساسية.
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow('Barcode', widget.barcode),
                const Divider(),
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
        _buildRawMaterialBalanceSection(),
        const SizedBox(height: 20),

        // أرصدة الصنف في المستودعات.
        _buildBalancesSection(),

        const SizedBox(height: 20),

        // مسح باركود جديد.
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

  // تحميل وعرض إجمالي رصيد الخامة.
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

  // تحميل وعرض أرصدة المستودعات.
  Widget _buildBalancesSection() {
    return BlocBuilder<ItemBalanceCubit, ItemBalanceState>(
      builder: (context, state) {
        if (state is ItemBalanceLoading || state is ItemBalanceInitial) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(color: goldColor),
              title: Text('Loading warehouse balances...'),
            ),
          );
        }

        if (state is ItemBalanceError) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.orange),
              title: const Text('Failed to load balances'),
              subtitle: Text(state.message),
            ),
          );
        }

        if (state is ItemBalanceSuccess) {
          final balances = state.balances;

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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

                  // إجمالي الأرصدة.
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

  // تنسيق الأرقام وإظهار منزلتين عشريتين.
  String _formatNumber(double? value) {
    return (value ?? 0).toStringAsFixed(2);
  }

  // صف مشترك لعرض اسم الخاصية وقيمتها.
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
