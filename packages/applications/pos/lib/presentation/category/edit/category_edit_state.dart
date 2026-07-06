// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';

@immutable
class CategoryEditState {
  final bool loading;
  final String? error;
  final Category? updated;
  final Category? removed;

  const CategoryEditState({
    this.loading = false,
    this.error,
    this.updated,
    this.removed,
  });

  CategoryEditState copyWith({
    bool? loading,
    String? error,
    Category? updated,
    Category? removed,
    bool clearError = false,
    bool clearUpdated = false,
    bool clearRemoved = false,
  }) {
    return CategoryEditState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      updated: clearUpdated ? null : (updated ?? this.updated),
      removed: clearRemoved ? null : (removed ?? this.removed),
    );
  }
}
