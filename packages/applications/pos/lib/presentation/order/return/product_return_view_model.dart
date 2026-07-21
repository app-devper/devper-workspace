// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product_return/param.dart';
import 'package:pos/domain/usecase/product_return/create_product_return_use_case.dart';
import 'package:pos/presentation/order/return/product_return_state.dart';

class ProductReturnViewModel {
  final CreateProductReturnUseCase createProductReturnUseCase;

  ProductReturnViewModel({
    required this.createProductReturnUseCase,
  });

  final _state = ValueNotifier<ProductReturnState>(const ProductReturnState());

  ValueListenable<ProductReturnState> get state => _state;

  Future<void> createProductReturn(CreateProductReturnParam param) async {
    _state.value = _state.value.copyWith(loading: true, clearError: true, clearCreated: true);
    try {
      final created = await createProductReturnUseCase(param);
      _state.value = _state.value.copyWith(loading: false, created: created);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void consumeCreated() {
    if (_state.value.created != null) {
      _state.value = _state.value.copyWith(clearCreated: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
