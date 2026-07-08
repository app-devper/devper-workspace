// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/usecase/category/get_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/remove_category_by_id_use_case.dart';
import 'package:pos/domain/usecase/category/update_category_by_id_use_case.dart';
import 'category_edit_state.dart';

class CategoryEditViewModel {
  final GetCategoryByIdUseCase getCategoryByIdUseCase;
  final UpdateCategoryByIdUseCase updateCategoryByIdUseCase;
  final RemoveCategoryByIdUseCase removeCategoryByIdUseCase;

  CategoryEditViewModel({
    required this.getCategoryByIdUseCase,
    required this.updateCategoryByIdUseCase,
    required this.removeCategoryByIdUseCase,
  });

  final _state = ValueNotifier<CategoryEditState>(const CategoryEditState());

  ValueListenable<CategoryEditState> get state => _state;

  Future<void> getCategoryById(String categoryId) async {
    try {
      await getCategoryByIdUseCase(categoryId);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> updateCategoryById(String categoryId, CategoryParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await updateCategoryByIdUseCase(
        CategoryUpdateParam(categoryId: categoryId, param: param),
      );
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeCategoryById(String categoryId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await removeCategoryByIdUseCase(categoryId);
      _state.value = _state.value.copyWith(loading: false, removed: removed);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
