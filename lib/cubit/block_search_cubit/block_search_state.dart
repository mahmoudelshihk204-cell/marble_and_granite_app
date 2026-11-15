
import 'package:equatable/equatable.dart';

import '../../models/legacy/legacy_block_model.dart';

// الحالات الأساسية لشاشة البحث عن البلوك
abstract class BlockSearchState extends Equatable {
  const BlockSearchState();

  @override
  List<Object?> get props => [];
}

// الحالة الأولية: لسه المستخدم مبدأش البحث
class BlockSearchInitial extends BlockSearchState {
  const BlockSearchInitial();
}

// حالة التحميل: جاري جلب بيانات البلوك من السيرفر
class BlockSearchLoading extends BlockSearchState {
  const BlockSearchLoading();
}

// حالة النجاح: تم العثور على البلوك
class BlockSearchSuccess extends BlockSearchState {
  final LegacyBlockModel block;

  const BlockSearchSuccess(this.block);

  @override
  List<Object?> get props => [block];
}

// حالة الخطأ: البلوك غير موجود أو حصلت مشكلة في الاتصال
class BlockSearchError extends BlockSearchState {
  final String message;

  const BlockSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
