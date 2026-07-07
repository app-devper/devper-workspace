// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/history/product_history_state.dart';

class ProductHistoryViewModel {
  final ProductRepository productRepo;

  ProductHistoryViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductHistoryState>(const ProductHistoryState());

  ValueListenable<ProductHistoryState> get state => _state;

  Future<void> getHistoriesByProductId(String productId) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      final items = await productRepo.getProductHistoriesByProductId(productId);
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
