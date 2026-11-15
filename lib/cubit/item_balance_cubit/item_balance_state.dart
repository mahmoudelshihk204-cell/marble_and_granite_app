
import 'package:marble_and_granite/models/legacy/legacy_balance_model.dart';

// الحالات المختلفة لتحميل أرصدة الصنف.
abstract class ItemBalanceState {
  const ItemBalanceState();
}

// الحالة الابتدائية.
class ItemBalanceInitial extends ItemBalanceState {
  const ItemBalanceInitial();
}

// أثناء تحميل الأرصدة.
class ItemBalanceLoading extends ItemBalanceState {
  const ItemBalanceLoading();
}

// عند نجاح تحميل الأرصدة.
class ItemBalanceSuccess extends ItemBalanceState {
  final List<LegacyBalanceModel> balances;

  const ItemBalanceSuccess(this.balances);
}

// عند حدوث خطأ.
class ItemBalanceError extends ItemBalanceState {
  final String message;

  const ItemBalanceError(this.message);
}

