// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/receive/param.dart';
import 'package:pos/domain/model/receive/receive.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/receive_repository.dart';

import 'receive_add_state.dart';


class ReceiveAddViewModel {
  final ReceiveRepository receiveRepo;
  final CategoryRepository categoryRepo;

  ReceiveAddViewModel({
    required this.receiveRepo,
    required this.categoryRepo,
  });

  final _states = StreamController<ReceiveAddState>();

  StreamController<ReceiveAddState> get states => _states;

  void getCategories() async {
    try {
      final result = await categoryRepo.getLocalCategories();
      _onGetCategoriesSuccess(result);
    } on Exception catch (_) {}
  }

  void createReceive(ReceiveParam param) async {
    _onLoading();
    try {
      final result = await receiveRepo.createReceive(param);
      _onCreateReceive(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    if (!_states.isClosed) {
      _states.sink.add(LoadingState());
    }
  }

  _onCreateReceive(Receive data) {
    if (!_states.isClosed) {
      //_states.sink.add(CreateReceiveState(data: data));
    }
  }

  _onGetCategoriesSuccess(List<Category> data) {
    if (!_states.isClosed) {
      _states.sink.add(GetCategoryState(data: data));
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
