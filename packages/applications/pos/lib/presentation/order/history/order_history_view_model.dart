// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/usecase/order/get_order_item_by_product_id_use_case.dart';
import 'order_history_state.dart';

class OrderHistoryViewModel {
  final GetOrderItemByProductIdUseCase getOrderItemByProductIdUseCase;

  OrderHistoryViewModel({
    required this.getOrderItemByProductIdUseCase,
  });

  final _state = ValueNotifier<OrderHistoryState>(const OrderHistoryState());

  /// Shown as a snackbar and then gone. It never belonged in state: a message
  /// the view had to remember to clear is one it can forget to clear.
  final _errors = OneShot<String>();

  ValueListenable<OrderHistoryState> get state => _state;

  Stream<String> get errors => _errors.stream;

  Future<void> getOrderItemByProductId(String productId) async {
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await getOrderItemByProductIdUseCase(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  void dispose() {
    _state.dispose();
    _errors.dispose();
  }
}
