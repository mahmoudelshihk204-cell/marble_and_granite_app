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
      emit(const BarcodeSearchError('Invalid Barcode'));
      return;
    }

    print('CUBIT: Emitting Loading');
    emit(const BarcodeSearchLoading());

    try {
      print('CUBIT: Calling Repository');

      final item = await blockRepository.getItemByBarcode(
        normalizedBarcode,
      );

      print('CUBIT: Repository returned');

      if (item == null) {
        print('CUBIT: Item is NULL');
        emit(const BarcodeSearchError('Item not found'));
        return;
      }

      print('CUBIT: Item received = ${item.itemCode}');
      print('CUBIT: Emitting Success');

      emit(BarcodeSearchSuccess(item));

      print('CUBIT: Success emitted');
    } catch (error, stackTrace) {
      print('CUBIT ERROR: $error');
      print(stackTrace);

      emit(BarcodeSearchError('Failed to search Barcode: $error'));
    }
  }
}
