
// الحالات الأساسية لجلب رصيد الخامة.
abstract class RawMaterialBalanceState {
  const RawMaterialBalanceState();
}

// الحالة الأولية قبل بدء الطلب.
class RawMaterialBalanceInitial extends RawMaterialBalanceState {
  const RawMaterialBalanceInitial();
}

// أثناء انتظار رد السيرفر.
class RawMaterialBalanceLoading extends RawMaterialBalanceState {
  const RawMaterialBalanceLoading();
}

// عند نجاح جلب رصيد الخامة.
class RawMaterialBalanceSuccess extends RawMaterialBalanceState {
  final double balance;

  const RawMaterialBalanceSuccess(this.balance);
}

// عند حدوث خطأ أثناء جلب الرصيد.
class RawMaterialBalanceError extends RawMaterialBalanceState {
  final String message;

  const RawMaterialBalanceError(this.message);
}
