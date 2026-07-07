// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/repositories/order_repository.dart';
import 'order_history_state.dart';

class OrderHistoryViewModel {
  final OrderRepository orderRepo;

  OrderHistoryViewModel({
    required this.orderRepo,
  });

  final _state = ValueNotifier<OrderHistoryState>(const OrderHistoryState());

  ValueListenable<OrderHistoryState> get state => _state;

  Future<void> getOrderItemByProductId(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await orderRepo.getOrderItemByProductId(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
