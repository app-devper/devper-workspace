// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/add_product_price_use_case.dart';
import 'package:pos/domain/usecase/product/get_product_prices_by_product_id_use_case.dart';
import 'package:pos/domain/usecase/product/remove_product_price_by_id_use_case.dart';
import 'package:pos/domain/usecase/product/update_product_price_by_id_use_case.dart';
import 'package:pos/presentation/product/price/product_price_state.dart';

class ProductPriceViewModel {
  final AddProductPriceUseCase addProductPriceUseCase;
  final UpdateProductPriceByIdUseCase updateProductPriceByIdUseCase;
  final RemoveProductPriceByIdUseCase removeProductPriceByIdUseCase;
  final GetProductPricesByProductIdUseCase getProductPricesByProductIdUseCase;

  ProductPriceViewModel({
    required this.addProductPriceUseCase,
    required this.updateProductPriceByIdUseCase,
    required this.removeProductPriceByIdUseCase,
    required this.getProductPricesByProductIdUseCase,
  });

  final _state = ValueNotifier<ProductPriceState>(const ProductPriceState());

  ValueListenable<ProductPriceState> get state => _state;

  Future<void> addProductPrice(ProductPriceParam param) async {
    await _run(() => addProductPriceUseCase(param));
  }

  Future<void> updateProductPriceById(
      String id, ProductPriceParam param) async {
    await _run(() => updateProductPriceByIdUseCase(
        ProductPriceUpdateParam(priceId: id, param: param)));
  }

  Future<void> removeProductPriceById(String id) async {
    await _run(() => removeProductPriceByIdUseCase(id));
  }

  Future<void> getProductPrice(String productId) async {
    _state.value = _state.value.copyWith(task: const ProductPriceRunning());
    try {
      final items = await getProductPricesByProductIdUseCase(productId);
      _state.value =
          _state.value.copyWith(task: const ProductPriceTask(), items: items);
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductPriceFailed(toFailure(e)));
    }
  }

  Future<void> _run(Future<ProductPrice> Function() action) async {
    _state.value = _state.value.copyWith(task: const ProductPriceRunning());
    try {
      final completed = await action();
      _state.value =
          _state.value.copyWith(task: ProductPriceCompleted(completed));
    } on Exception catch (e) {
      _state.value =
          _state.value.copyWith(task: ProductPriceFailed(toFailure(e)));
    }
  }

  void consumeError() {
    if (_state.value.task is ProductPriceFailed) {
      _state.value = _state.value.copyWith(task: const ProductPriceTask());
    }
  }

  void consumeCompleted() {
    if (_state.value.task is ProductPriceCompleted) {
      _state.value = _state.value.copyWith(task: const ProductPriceTask());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
