// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/order/get_order_item_by_product_id_use_case.dart';
import 'order_history_state.dart';

class OrderHistoryViewModel {
  final GetOrderItemByProductIdUseCase getOrderItemByProductIdUseCase;

  OrderHistoryViewModel({
    required this.getOrderItemByProductIdUseCase,
  });

  final _state = ValueNotifier<OrderHistoryState>(const OrderHistoryState());

  ValueListenable<OrderHistoryState> get state => _state;

  Future<void> getOrderItemByProductId(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getOrderItemByProductIdUseCase(productId);
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
