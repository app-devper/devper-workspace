// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'category_add_state.dart';

class CategoryAddViewModel {
  final CategoryRepository categoryRepo;

  CategoryAddViewModel({
    required this.categoryRepo,
  });

  final _states = StreamController<CategoryAddState>();

  StreamController<CategoryAddState> get states => _states;

  void createCategory(CategoryParam param) async {
    _onLoading();
    try {
      final result = await categoryRepo.createCategory(param);
      _onCreateCategory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onCreateCategory(Category data) {
    if (!_states.isClosed) {
      _states.sink.add(CreateCategoryState(data: data));
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
