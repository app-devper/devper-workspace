// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/usecase/product_return/get_product_returns_by_order_id_use_case.dart';
import 'package:pos/presentation/order/return/product_returns_history_state.dart';

class ProductReturnsHistoryViewModel {
  final GetProductReturnsByOrderIdUseCase getProductReturnsByOrderIdUseCase;

  ProductReturnsHistoryViewModel({
    required this.getProductReturnsByOrderIdUseCase,
  });

  final _state = ValueNotifier<ProductReturnsHistoryState>(const ProductReturnsHistoryState());

  ValueListenable<ProductReturnsHistoryState> get state => _state;

  Future<void> getProductReturnsByOrderId(String orderId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await getProductReturnsByOrderIdUseCase(orderId);
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
