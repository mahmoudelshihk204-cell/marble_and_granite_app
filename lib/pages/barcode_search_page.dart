
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/barcode_search_cubit/barcode_search_cubit.dart';
import '../cubit/barcode_search_cubit/barcode_search_state.dart';
import '../models/legacy/legacy_item_model.dart';
import '../repositories/block_repository.dart';

class BarcodeSearchPage extends StatefulWidget {
  const BarcodeSearchPage({super.key});

  @override
  State<BarcodeSearchPage> createState() => _BarcodeSearchPageState();
}

class _BarcodeSearchPageState extends State<BarcodeSearchPage> {
  static const goldColor = Color(0xffC5A46D);

  late final BarcodeSearchCubit cubit;

  // Controller لاستقبال الباركود مع الحفاظ على الأصفار في البداية.
  final TextEditingController barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // استخدام Repository المسجل بالفعل في main.dart.
    final repository = context.read<BlockRepository>();

    cubit = BarcodeSearchCubit(repository);
  }

  @override
  void dispose() {
    barcodeController.dispose();
    cubit.close();
    super.dispose();
  }

  void _searchBarcode() {
    cubit.searchBarcode(barcodeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<BarcodeSearchCubit, BarcodeSearchState>(
        builder: (context, state) {
          final isLoading = state is BarcodeSearchLoading;

          final errorMessage = state is BarcodeSearchError
              ? state.message
              : null;

          final item = state is BarcodeSearchSuccess
              ? state.item
              : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Barcode Search'),
              backgroundColor: Colors.black,
              foregroundColor: goldColor,
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.qr_code_scanner,
                      color: goldColor,
                    ),
                    title: Text('Stock Barcode Search'),
                    subtitle: Text('Search Oracle inventory items'),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Enter Barcode',
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
                        controller: barcodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchBarcode(),
                        decoration: const InputDecoration(
                          labelText: 'EAN-8 Barcode',
                          hintText: 'Example: 00022798',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _searchBarcode,
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
                      child: CircularProgressIndicator(
                        color: goldColor,
                      ),
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

                if (!isLoading && item != null)
                  _buildItemDetails(item),
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

  // صف موحد لعرض اسم الخاصية وقيمتها.
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
