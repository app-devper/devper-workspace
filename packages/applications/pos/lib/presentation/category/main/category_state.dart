// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Project imports:
import 'package:pos/domain/model/category/category.dart';

@immutable
class CategoryState {
  final List<Category> items;
  final bool loading;

  const CategoryState({
    this.items = const [],
    this.loading = false,
  });

  CategoryState copyWith({
    List<Category>? items,
    bool? loading,
  }) {
    return CategoryState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
    );
  }
}
