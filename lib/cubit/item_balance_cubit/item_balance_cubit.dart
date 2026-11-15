
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'item_balance_state.dart';

class ItemBalanceCubit extends Cubit<ItemBalanceState> {
  final BlockRepository repository;

  ItemBalanceCubit(this.repository) : super(const ItemBalanceInitial());

  // تحميل أرصدة الصنف باستخدام Item Code.
  Future<void> fetchBalances(String itemCode) async {
    emit(const ItemBalanceLoading());

    try {
      final balances = await repository.getItemBalances(itemCode);

      emit(ItemBalanceSuccess(balances));
    } catch (error) {
      emit(ItemBalanceError('Failed to load balances: $error'));
    }
  }
}
