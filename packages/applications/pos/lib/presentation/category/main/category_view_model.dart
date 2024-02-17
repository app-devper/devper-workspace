// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'category_state.dart';

class CategoryViewModel {
  final CategoryRepository categoryRepo;

  CategoryViewModel({
    required this.categoryRepo,
  });

  final _states = StreamController<CategoryState>();

  StreamController<CategoryState> get states => _states;

  final _categories = StreamController<List<Category>>();

  StreamController<List<Category>> get categories => _categories;

  void getCategories() async {
    try {
      final result = await categoryRepo.getCategories();
      _onListCategory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void updateDefaultCategoryById(String categoryId) async {
    _onLoading();
    try {
      final result = await categoryRepo.updateDefaultCategoryById(categoryId);
      _onUpdateCategory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  void setCategories(List<Category> data) {
    if (!_categories.isClosed) {
      _categories.sink.add(data);
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onListCategory(List<Category> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListCategoryState(data: data));
    }
  }

  _onUpdateCategory(Category data) {
    if (!_states.isClosed) {
      _states.sink.add((UpdateCategoryState(data: data)));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(message: failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
    _categories.close();
  }
}
