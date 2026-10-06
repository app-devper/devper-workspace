// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'category_edit_state.dart';

import 'package:pos/domain/repositories/category_repository.dart';

class CategoryEditViewModel {
  final CategoryRepository categoryRepo;

  CategoryEditViewModel({
    required this.categoryRepo,
  });

  final _state = ValueNotifier<CategoryEditState>(const CategoryEditState());

  /// Each outcome reaches the view once: a snackbar, or a pop with the record.
  /// Neither is drawn, so neither sits in state waiting to be cleared.
  final _updated = OneShot<Category>();
  final _removed = OneShot<Category>();
  final _errors = OneShot<String>();

  ValueListenable<CategoryEditState> get state => _state;

  Stream<Category> get updated => _updated.stream;

  Stream<Category> get removed => _removed.stream;

  Stream<String> get errors => _errors.stream;

  /// Fetches the record and throws the result away — the page already has the
  /// category it was opened with. All this does is report a failure, which is
  /// why it only touches the error channel.
  Future<void> getCategoryById(String categoryId) async {
    try {
      await categoryRepo.getCategoryById(categoryId);
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> updateCategoryById(
      String categoryId, CategoryParam param) async {
    if (_state.value.busy) return;
    _state.value = _state.value.copyWith(busy: true);
    try {
      _updated.emit(await categoryRepo.updateCategoryById(categoryId, param));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  Future<void> removeCategoryById(String categoryId) async {
    if (_state.value.busy) return;
    _state.value = _state.value.copyWith(busy: true);
    try {
      _removed.emit(await categoryRepo.removeCategoryById(categoryId));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(busy: false);
    }
  }

  void dispose() {
    _state.dispose();
    _updated.dispose();
    _removed.dispose();
    _errors.dispose();
  }
}
