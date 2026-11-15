
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'item_code_search_state.dart';

class ItemCodeSearchCubit extends Cubit<ItemCodeSearchState> {
  final BlockRepository blockRepository;

  ItemCodeSearchCubit(this.blockRepository)
      : super(const ItemCodeSearchInitial());

  // البحث اليدوي باستخدام Item Code.
  Future<void> searchItemCode(String itemCode) async {
    final normalizedCode = itemCode.trim();

    if (normalizedCode.isEmpty) {
      emit(const ItemCodeSearchError('Please enter Item Code'));
      return;
    }

    emit(const ItemCodeSearchLoading());

    try {
      final item = await blockRepository.getItemByCode(normalizedCode);

      if (item == null) {
        emit(const ItemCodeSearchError('Item not found'));
        return;
      }

      emit(ItemCodeSearchSuccess(item));
    } catch (error) {
      emit(ItemCodeSearchError('Failed to search Item Code: $error'));
    }
  }

  // البحث تلقائياً باستخدام Barcode المقروء من الكاميرا.
  Future<void> searchBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();

    if (normalizedBarcode.isEmpty) {
      emit(const ItemCodeSearchError('Invalid Barcode'));
      return;
    }

    emit(const ItemCodeSearchLoading());

    try {
      final item = await blockRepository.getItemByBarcode(
        normalizedBarcode,
      );

      if (item == null) {
        emit(const ItemCodeSearchError('Item not found'));
        return;
      }

      emit(ItemCodeSearchSuccess(item));
    } catch (error) {
      emit(ItemCodeSearchError('Failed to search Barcode: $error'));
    }
  }
}
