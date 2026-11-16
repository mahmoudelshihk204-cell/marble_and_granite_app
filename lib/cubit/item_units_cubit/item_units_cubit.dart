import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/block_repository.dart';
import 'item_units_state.dart';

class ItemUnitsCubit extends Cubit<ItemUnitsState> {
  final BlockRepository repository;

  ItemUnitsCubit(this.repository) : super(const ItemUnitsInitial());

  // جلب وحدات الصنف من خلال Repository.
  Future<void> fetchUnits(String itemCode) async {
    emit(const ItemUnitsLoading());

    try {
      final units = await repository.getItemUnits(itemCode);

      if (units.isEmpty) {
        emit(const ItemUnitsSuccess([]));
        return;
      }

      emit(ItemUnitsSuccess(units));
    } catch (error) {
      emit(ItemUnitsError('Failed to load item units: $error'));
    }
  }
}