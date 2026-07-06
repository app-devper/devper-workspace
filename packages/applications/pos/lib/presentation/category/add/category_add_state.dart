// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';

@immutable
class CategoryAddState {
  final bool saving;
  final String? error;
  final Category? created;

  const CategoryAddState({
    this.saving = false,
    this.error,
    this.created,
  });

  CategoryAddState copyWith({
    bool? saving,
    String? error,
    Category? created,
    bool clearError = false,
    bool clearCreated = false,
  }) {
    return CategoryAddState(
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      created: clearCreated ? null : (created ?? this.created),
    );
  }
}
