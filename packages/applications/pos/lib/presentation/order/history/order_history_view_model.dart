// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/order/order_item_detail.dart';
import 'package:pos/domain/repositories/order_repository.dart';
import 'order_history_state.dart';

class OrderHistoryViewModel {
  final OrderRepository orderRepo;

  OrderHistoryViewModel({
    required this.orderRepo,
  });

  final _states = StreamController<OrderHistoryState>();

  StreamController<OrderHistoryState> get states => _states;

  void getOrderItemByProductId(String productId) async {
    _onLoading();
    try {
      final result = await orderRepo.getOrderItemByProductId(productId);
      _onGetOrderItem(result);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onLoading() {
    _states.sink.add(LoadingState());
  }

  _onGetOrderItem(List<OrderItemDetail> items) {
    if (!_states.isClosed) {
      _states.sink.add(OrderItemState(items));
    }
  }

  _onError(Failure failure) {
    if (!_states.isClosed) {
      _states.sink.add(ErrorState(failure.getMessage()));
    }
  }

  dispose() {
    _states.close();
  }
}
