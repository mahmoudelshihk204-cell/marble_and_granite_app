import 'package:equatable/equatable.dart';

import '../../models/legacy/legacy_unit_model.dart';

// الحالات المختلفة لتحميل وحدات الصنف.
abstract class ItemUnitsState extends Equatable {
  const ItemUnitsState();

  @override
  List<Object?> get props => [];
}

// الحالة الابتدائية قبل طلب الوحدات.
class ItemUnitsInitial extends ItemUnitsState {
  const ItemUnitsInitial();
}

// أثناء تحميل الوحدات من السيرفر.
class ItemUnitsLoading extends ItemUnitsState {
  const ItemUnitsLoading();
}

// عند نجاح تحميل الوحدات.
class ItemUnitsSuccess extends ItemUnitsState {
  final List<LegacyUnitModel> units;

  const ItemUnitsSuccess(this.units);

  @override
  List<Object?> get props => [units];
}

// عند حدوث خطأ أثناء التحميل.
class ItemUnitsError extends ItemUnitsState {
  final String message;

  const ItemUnitsError(this.message);

  @override
  List<Object?> get props => [message];
}