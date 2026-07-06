// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';

@immutable
class CategoryState {
  final List<Category> items;
  final bool loading;
  final String? error;

  const CategoryState({
    this.items = const [],
    this.loading = false,
    this.error,
  });

  CategoryState copyWith({
    List<Category>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return CategoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
