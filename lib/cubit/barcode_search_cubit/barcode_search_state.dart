
import 'package:equatable/equatable.dart';

import '../../models/legacy/legacy_item_model.dart';

// الحالات المختلفة للبحث بالباركود.
abstract class BarcodeSearchState extends Equatable {
  const BarcodeSearchState();

  @override
  List<Object?> get props => [];
}

// الحالة الأولية قبل بدء البحث.
class BarcodeSearchInitial extends BarcodeSearchState {
  const BarcodeSearchInitial();
}

// أثناء الاتصال بالسيرفر.
class BarcodeSearchLoading extends BarcodeSearchState {
  const BarcodeSearchLoading();
}

// عند نجاح البحث.
class BarcodeSearchSuccess extends BarcodeSearchState {
  final LegacyItemModel item;

  const BarcodeSearchSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

// عند حدوث خطأ أو عدم العثور على الصنف.
class BarcodeSearchError extends BarcodeSearchState {
  final String message;

  const BarcodeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
