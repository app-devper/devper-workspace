// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/stock/product_stock_sequence_state.dart';

class ProductStockSequenceViewModel {
  final ProductRepository productRepo;

  ProductStockSequenceViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductStockSequenceState>(const ProductStockSequenceState());

  ValueListenable<ProductStockSequenceState> get state => _state;

  Future<void> updateProductStockSequenceById(UpdateProductStockSequenceParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearUpdated: true);
    try {
      final updated = await productRepo.updateProductStockSequence(param);
      _state.value = _state.value.copyWith(loading: false, updated: updated);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeUpdated() {
    if (_state.value.updated != null) {
      _state.value = _state.value.copyWith(clearUpdated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
