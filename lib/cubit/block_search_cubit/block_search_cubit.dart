
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'block_search_state.dart';

// مسؤول عن إدارة حالات البحث عن البلوك
class BlockSearchCubit extends Cubit<BlockSearchState> {
  final BlockRepository blockRepository;

  BlockSearchCubit(this.blockRepository)
      : super(const BlockSearchInitial());

  // البحث عن البلوك باستخدام رقمه
  Future<void> searchBlock(String blockNumber) async {
    final number = blockNumber.trim();

    if (number.isEmpty) {
      emit(const BlockSearchError('Please enter a block number'));
      return;
    }

    emit(const BlockSearchLoading());

    try {
      // طلب البيانات من Repository بدل الاتصال المباشر بالسيرفر
      final block = await blockRepository.getBlockByNumber(number);

      if (block == null) {
        emit(const BlockSearchError('Block not found'));
        return;
      }

      emit(BlockSearchSuccess(block));
    } catch (e) {
      emit(BlockSearchError('Failed to search block: $e'));
    }
  }
}
