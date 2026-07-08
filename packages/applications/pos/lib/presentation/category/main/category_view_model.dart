// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/category/get_categories_use_case.dart';
import 'package:pos/domain/usecase/category/update_default_category_by_id_use_case.dart';
import 'category_state.dart';

class CategoryViewModel {
  final GetCategoriesUseCase getCategoriesUseCase;
  final UpdateDefaultCategoryByIdUseCase updateDefaultCategoryByIdUseCase;

  CategoryViewModel({
    required this.getCategoriesUseCase,
    required this.updateDefaultCategoryByIdUseCase,
  });

  final _state = ValueNotifier<CategoryState>(const CategoryState());

  ValueListenable<CategoryState> get state => _state;

  Future<void> getCategories() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getCategoriesUseCase();
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> updateDefaultCategoryById(String categoryId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      await updateDefaultCategoryByIdUseCase(categoryId);
      await getCategories();
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
