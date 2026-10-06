// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/presentation/order/return/product_returns_history_state.dart';
import 'package:pos/domain/repositories/product_return_repository.dart';

class ProductReturnsHistoryViewModel {
  final ProductReturnRepository productReturnRepo;

  ProductReturnsHistoryViewModel({
    required this.productReturnRepo,
  });

  final _state = ValueNotifier<ProductReturnsHistoryState>(
      const ProductReturnsHistoryState());

  ValueListenable<ProductReturnsHistoryState> get state => _state;

  Future<void> getProductReturnsByOrderId(String orderId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await productReturnRepo.getProductReturnsByOrderId(orderId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
