
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:marble_and_granite/Widgets/legacy/item_information_card.dart';
import 'package:marble_and_granite/Widgets/legacy/warehouse_balances_section.dart';
import 'package:marble_and_granite/pages/scanner_page.dart';

import '../cubit/barcode_search_cubit/barcode_search_cubit.dart';
import '../cubit/barcode_search_cubit/barcode_search_state.dart';
import '../models/legacy/legacy_item_model.dart';
import '../repositories/block_repository.dart';

class BarcodeResultPage extends StatefulWidget {
  final String barcode;

  const BarcodeResultPage({
    super.key,
    required this.barcode,
  });

  @override
  State<BarcodeResultPage> createState() => _BarcodeResultPageState();
}

class _BarcodeResultPageState extends State<BarcodeResultPage> {
  static const goldColor = Color(0xffC5A46D);

  late final BarcodeSearchCubit cubit;

  @override
  void initState() {
    super.initState();

    // الحصول على Repository الموجود بالفعل في التطبيق.
    final repository = context.read<BlockRepository>();

    // إنشاء Cubit خاص بالبحث بالباركود.
    cubit = BarcodeSearchCubit(repository);

    // بدء البحث تلقائياً بمجرد فتح الصفحة.
    cubit.searchBarcode(widget.barcode);
  }

  @override
  void dispose() {
    // إغلاق Cubit عند مغادرة الصفحة.
    cubit.close();
    super.dispose();
  }

  // فتح الكاميرا لمسح باركود جديد.
  Future<void> _scanAnotherBarcode() async {
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerPage(),
      ),
    );

    if (!mounted || barcode == null || barcode.trim().isEmpty) {
      return;
    }

    // فتح صفحة جديدة بنتيجة الباركود الجديد.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeResultPage(
          barcode: barcode.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<BarcodeSearchCubit, BarcodeSearchState>(
        builder: (context, state) {
          // متابعة الحالة الحالية للبحث.
          print('UI RECEIVED STATE: ${state.runtimeType}');

          final isLoading = state is BarcodeSearchLoading;

          final item = state is BarcodeSearchSuccess
              ? state.item
              : null;

          final errorMessage = state is BarcodeSearchError
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
                    ? const CircularProgressIndicator(
                        color: goldColor,
                      )
                    : errorMessage != null
                        ? _buildError(errorMessage)
                        :  item != null
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
        leading: const Icon(
          Icons.error_outline,
          color: Colors.orange,
        ),
        title: Text(message),
      ),
    );
  }

  // عرض بيانات الصنف والأرصدة.
  Widget _buildItemDetails(LegacyItemModel item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: ListTile(
            leading: Icon(
              Icons.qr_code_scanner,
              color: goldColor,
            ),
            title: Text('Barcode Search Result'),
            subtitle: Text('Item information from TopSoftware'),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Item Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ItemInformationCard(
              item: item,
              barcode: widget.barcode,
            ),
          ),
        ),

        const SizedBox(height: 16),

        WarehouseBalancesSection(
          balances: item.warehouseBalances,
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _scanAnotherBarcode,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text(
              'Scan Another Barcode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
