// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/category_repository.dart';
import 'package:pos/domain/repositories/product_repository.dart';

import 'receive_edit_state.dart';


class ReceiveEditViewModel {
  final ProductRepository productRepo;
  final CategoryRepository categoryRepo;

  ReceiveEditViewModel({
    required this.productRepo,
    required this.categoryRepo,
  });

  final _states = StreamController<ReceiveEditState>();

  Stream<ReceiveEditState> get states => _states.stream;


  _onLoading() {
    _states.sink.add(LoadingState());
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
