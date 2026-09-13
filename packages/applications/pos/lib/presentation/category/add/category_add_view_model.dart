// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/category/param.dart';
import 'package:pos/domain/usecase/category/create_category_use_case.dart';
import 'category_add_state.dart';

class CategoryAddViewModel {
  final CreateCategoryUseCase createCategoryUseCase;

  CategoryAddViewModel({
    required this.createCategoryUseCase,
  });

  final _state = ValueNotifier<CategoryAddState>(const CategoryAddState());

  /// The two things the screen reacts to once each. Neither is drawn, so
  /// neither belongs in state, and there is nothing for the view to clear.
  final _created = OneShot<Category>();
  final _errors = OneShot<String>();

  ValueListenable<CategoryAddState> get state => _state;

  Stream<Category> get created => _created.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> createCategory(CategoryParam param) async {
    if (_state.value.saving) return;
    _state.value = _state.value.copyWith(saving: true);
    try {
      _created.emit(await createCategoryUseCase(param));
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(saving: false);
    }
  }

  void dispose() {
    _state.dispose();
    _created.dispose();
    _errors.dispose();
  }
}
