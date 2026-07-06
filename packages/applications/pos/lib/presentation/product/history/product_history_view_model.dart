// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product_history.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/history/product_history_state.dart';

class ProductHistoryViewModel {
  final ProductRepository productRepo;

  ProductHistoryViewModel({
    required this.productRepo,
  });

  final _states = StreamController<ProductHistoryState>();

  Stream<ProductHistoryState> get states => _states.stream;

  void getHistoriesByProductId(String productId) async {
    _onLoading();
    try {
      final result = await productRepo.getProductHistoriesByProductId(productId);
      _onListHistory(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    if (!_states.isClosed) {
      _states.sink.add(LoadingState());
    }
  }

  _onListHistory(List<ProductHistory> data) {
    if (!_states.isClosed) {
      _states.sink.add(ListHistoryState(data: data));
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
