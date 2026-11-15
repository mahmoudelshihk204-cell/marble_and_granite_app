
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'raw_material_balance_state.dart';

class RawMaterialBalanceCubit extends Cubit<RawMaterialBalanceState> {
  final BlockRepository repository;

  RawMaterialBalanceCubit(this.repository)
      : super(const RawMaterialBalanceInitial());

  // جلب إجمالي رصيد الخامة المرتبطة بكود الصنف.
  Future<void> fetchBalance(String itemCode) async {
    // طباعة كود الصنف للتأكد إن الكود الصحيح وصل للـ API.
    debugPrint('RAW BALANCE - Item Code: $itemCode');

    emit(const RawMaterialBalanceLoading());

    try {
      final balance = await repository.getRawMaterialBalance(itemCode);

      // طباعة الرصيد المستلم من السيرفر.
      debugPrint('RAW BALANCE - Response: $balance');

      emit(RawMaterialBalanceSuccess(balance));
    } catch (error, stackTrace) {
      // طباعة الخطأ الحقيقي وتفاصيل مكان حدوثه.
      debugPrint('RAW BALANCE - ERROR: $error');
      debugPrint('RAW BALANCE - STACK TRACE: $stackTrace');

      emit(
        RawMaterialBalanceError(
          'Failed to load raw material balance: $error',
        ),
      );
    }
  }
}
