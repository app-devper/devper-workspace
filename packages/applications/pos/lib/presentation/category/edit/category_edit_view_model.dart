// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'category_edit_state.dart';

class CategoryEditViewModel {
  final CategoryRepository categoryRepo;

  CategoryEditViewModel({
    required this.categoryRepo,
  });

  final _states = StreamController<CategoryEditState>();

  StreamController<CategoryEditState> get states => _states;

  void getCategoryById(String categoryId) async {
    try {
      final result = await categoryRepo.getCategoryById(categoryId);
      _onGetCategory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateCategoryById(String categoryId, CategoryParam param) async {
    _onLoading();
    try {
      final result = await categoryRepo.updateCategoryById(categoryId, param);
      _onEditCategory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void removeCategoryById(String categoryId) async {
    _onLoading();
    try {
      final result = await categoryRepo.removeCategoryById(categoryId);
      _onRemoveCategory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onRemoveCategory(Category data) {
    if (!_states.isClosed) {
      _states.sink.add(RemoveCategoryState(data: data));
    }
  }

  _onGetCategory(Category data) {
    if (!_states.isClosed) {
      _states.sink.add(GetCategoryState(data: data));
    }
  }

  _onEditCategory(Category data) {
    if (!_states.isClosed) {
      _states.sink.add(UpdateCategoryState(data: data));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
