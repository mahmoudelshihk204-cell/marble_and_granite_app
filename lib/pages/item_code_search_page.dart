
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/item_code_search_cubit/item_code_search_cubit.dart';
import '../cubit/item_code_search_cubit/item_code_search_state.dart';
import '../models/legacy/legacy_item_model.dart';
import '../repositories/block_repository.dart';

class ItemCodeSearchPage extends StatefulWidget {
  const ItemCodeSearchPage({super.key});

  @override
  State<ItemCodeSearchPage> createState() => _ItemCodeSearchPageState();
}

class _ItemCodeSearchPageState extends State<ItemCodeSearchPage> {
  static const goldColor = Color(0xffC5A46D);

  late final ItemCodeSearchCubit cubit;

  // Controller لاستقبال رقم الصنف.
  final TextEditingController itemCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // استخدام Repository المسجل بالفعل في main.dart.
    final repository = context.read<BlockRepository>();

    cubit = ItemCodeSearchCubit(repository);
  }

  @override
  void dispose() {
    itemCodeController.dispose();
    cubit.close();
    super.dispose();
  }

  // تنفيذ البحث باستخدام Item Code.
  void _searchItemCode() {
    cubit.searchItemCode(itemCodeController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ItemCodeSearchCubit, ItemCodeSearchState>(
        builder: (context, state) {
          final isLoading = state is ItemCodeSearchLoading;

          final errorMessage = state is ItemCodeSearchError
              ? state.message
              : null;

          final item = state is ItemCodeSearchSuccess
              ? state.item
              : null;

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
                    leading: Icon(
                      Icons.inventory_2,
                      color: goldColor,
                    ),
                    title: Text('Item Code Search'),
                    subtitle: Text('Search Oracle inventory items'),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Enter Item Code',
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
