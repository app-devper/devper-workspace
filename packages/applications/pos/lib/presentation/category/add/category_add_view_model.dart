// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/usecase/category/create_category_use_case.dart';
import 'category_add_state.dart';

class CategoryAddViewModel {
  final CreateCategoryUseCase createCategoryUseCase;

  CategoryAddViewModel({
    required this.createCategoryUseCase,
  });

  final _state = ValueNotifier<CategoryAddState>(const CategoryAddState());

  ValueListenable<CategoryAddState> get state => _state;

  Future<void> createCategory(CategoryParam param) async {
    _state.value = _state.value.copyWith(task: const CategoryAddRunning());
    try {
      final created = await createCategoryUseCase(param);
      _state.value = _state.value.copyWith(task: CategoryAddCreated(created));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: CategoryAddFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is CategoryAddFailed) {
      _state.value = _state.value.copyWith(task: const CategoryAddTask());
    }
  }

  void consumeCreated() {
    if (_state.value.task is CategoryAddCreated) {
      _state.value = _state.value.copyWith(task: const CategoryAddTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
