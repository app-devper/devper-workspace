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
      _state.value = CategoryEditFailed(toFailure(e));
    }
  }

  Future<void> updateCategoryById(String categoryId, CategoryParam param) async {
    if (_state.value is CategoryEditSaving) return;
    _state.value = const CategoryEditSaving();
    try {
      final updated = await updateCategoryByIdUseCase(
        CategoryUpdateParam(categoryId: categoryId, param: param),
      );
      _state.value = CategoryEditUpdated(updated);
    } on Exception catch (e) {
      _state.value = CategoryEditFailed(toFailure(e));
    }
  }

  Future<void> removeCategoryById(String categoryId) async {
    if (_state.value is CategoryEditDeleting) return;
    _state.value = const CategoryEditDeleting();
    try {
      final removed = await removeCategoryByIdUseCase(categoryId);
      _state.value = CategoryEditRemoved(removed);
    } on Exception catch (e) {
      _state.value = CategoryEditFailed(toFailure(e));
    }
  }

  void consumeError() {
    if (_state.value is CategoryEditFailed) {
      _state.value = const CategoryEditState();
    }
  }

  void consumeUpdated() {
    if (_state.value is CategoryEditUpdated) {
      _state.value = const CategoryEditState();
    }
  }

  void consumeRemoved() {
    if (_state.value is CategoryEditRemoved) {
      _state.value = const CategoryEditState();
    }
  }

  void dispose() {
    _state.dispose();
  }
}
