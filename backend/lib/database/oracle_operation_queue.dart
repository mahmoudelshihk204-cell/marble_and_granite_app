
import 'dart:async';

/// طابور لتنظيم عمليات قاعدة بيانات Oracle.
/// بيضمن تنفيذ عملية واحدة فقط في كل مرة على نفس الاتصال.
class OracleOperationQueue {
  // العملية الأخيرة في الطابور.
  Future<void> _tail = Future<void>.value();

  /// إضافة عملية جديدة للطابور وتنفيذها بعد انتهاء العملية السابقة.
  Future<T> run<T>(Future<T> Function() operation) {
    final completer = Completer<T>();

    // كل عملية جديدة تستنى انتهاء العملية اللي قبلها.
    _tail = _tail.then((_) async {
      try {
        // تنفيذ العملية الحالية.
        final result = await operation();

        // إرجاع النتيجة لصاحب الطلب.
        completer.complete(result);
      } catch (error, stackTrace) {
        // تمرير الخطأ مع StackTrace لصاحب الطلب.
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }
}
