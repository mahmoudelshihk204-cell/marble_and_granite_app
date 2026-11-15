
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'barcode_search_state.dart';

class BarcodeSearchCubit extends Cubit<BarcodeSearchState> {
  final BlockRepository blockRepository;

  BarcodeSearchCubit(this.blockRepository)
      : super(const BarcodeSearchInitial());

  // تنفيذ البحث باستخدام الباركود.
  Future<void> searchBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();

    if (normalizedBarcode.isEmpty) {
      emit(const BarcodeSearchError('Please enter a barcode'));
      return;
    }

    emit(const BarcodeSearchLoading());

    try {
      final item = await blockRepository.getItemByBarcode(
        normalizedBarcode,
      );

      if (item == null) {
        emit(const BarcodeSearchError('Item not found'));
        return;
      }

      emit(BarcodeSearchSuccess(item));
    } catch (error) {
      emit(BarcodeSearchError('Failed to search barcode: $error'));
    }
  }
}
