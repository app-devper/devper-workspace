// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'category_edit_state.dart';

class CategoryEditViewModel {
  final CategoryRepository categoryRepo;

  CategoryEditViewModel({
    required this.categoryRepo,
  });

  final _state = ValueNotifier<CategoryEditState>(const CategoryEditState());

  ValueListenable<CategoryEditState> get state => _state;

  Future<void> getCategoryById(String categoryId) async {
    try {
      await categoryRepo.getCategoryById(categoryId);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(error: toFailure(e).getMessage());
    }
  }

  Future<void> updateCategoryById(String categoryId, CategoryParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await categoryRepo.updateCategoryById(categoryId, param);
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  Future<void> removeCategoryById(String categoryId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearRemoved: true);
    try {
      final removed = await categoryRepo.removeCategoryById(categoryId);
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
