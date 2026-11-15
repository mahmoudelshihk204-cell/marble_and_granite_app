
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'item_code_search_state.dart';

// Cubit مسؤول عن إدارة عملية البحث باستخدام Item Code.
class ItemCodeSearchCubit extends Cubit<ItemCodeSearchState> {
  final BlockRepository blockRepository;

  ItemCodeSearchCubit(this.blockRepository)
      : super(const ItemCodeSearchInitial());

  // البحث عن الصنف من خلال الـ Item Code.
  Future<void> searchItemCode(String itemCode) async {
    final normalizedCode = itemCode.trim();

    // التأكد إن المستخدم أدخل رقم الصنف.
    if (normalizedCode.isEmpty) {
      emit(const ItemCodeSearchError('Please enter Item Code'));
      return;
    }

    emit(const ItemCodeSearchLoading());

    try {
      // إرسال رقم الصنف للـ Repository.
      final item = await blockRepository.getItemByCode(normalizedCode);

      if (item == null) {
        emit(const ItemCodeSearchError('Item not found'));
        return;
      }

      // البحث نجح، نرسل بيانات الصنف للواجهة.
      emit(ItemCodeSearchSuccess(item));
    } catch (error) {
      emit(ItemCodeSearchError('Failed to search Item Code: $error'));
    }
  }
}
