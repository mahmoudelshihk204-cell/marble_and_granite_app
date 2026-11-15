
import 'package:equatable/equatable.dart';

import '../../models/legacy/legacy_item_model.dart';

// الحالات المختلفة لعملية البحث باستخدام Item Code.
abstract class ItemCodeSearchState extends Equatable {
  const ItemCodeSearchState();

  @override
  List<Object?> get props => [];
}

// الحالة الأولية قبل بدء البحث.
class ItemCodeSearchInitial extends ItemCodeSearchState {
  const ItemCodeSearchInitial();
}

// أثناء انتظار نتيجة البحث من السيرفر.
class ItemCodeSearchLoading extends ItemCodeSearchState {
  const ItemCodeSearchLoading();
}

// عند نجاح البحث ووجود الصنف.
class ItemCodeSearchSuccess extends ItemCodeSearchState {
  final LegacyItemModel item;

  const ItemCodeSearchSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

// عند حدوث خطأ أو عدم العثور على الصنف.
class ItemCodeSearchError extends ItemCodeSearchState {
  final String message;

  const ItemCodeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

