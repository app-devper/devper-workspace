// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'category_add_state.dart';

class CategoryAddViewModel {
  final CategoryRepository categoryRepo;

  CategoryAddViewModel({
    required this.categoryRepo,
  });

  final _state = ValueNotifier<CategoryAddState>(const CategoryAddState());

  ValueListenable<CategoryAddState> get state => _state;

  Future<void> createCategory(CategoryParam param) async {
    _state.value = _state.value.copyWith(saving: true, clearError: true, clearCreated: true);
    try {
      final created = await categoryRepo.createCategory(param);
      _state.value = _state.value.copyWith(saving: false, created: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(saving: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
