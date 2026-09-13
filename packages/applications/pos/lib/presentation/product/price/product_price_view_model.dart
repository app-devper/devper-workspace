// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

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

  /// Delivered once and gone: the sheet closes on it, nothing draws it.
  final _completed = OneShot<ProductPrice>();
  final _errors = OneShot<String>();

  ValueListenable<ProductPriceState> get state => _state;

  Stream<ProductPrice> get completed => _completed.stream;

  Stream<String> get errors => _errors.stream;

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
    _state.value = _state.value.copyWith(loading: true);
    try {
      final items = await getProductPricesByProductIdUseCase(productId);
      _state.value = _state.value.copyWith(loading: false, items: items);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false);
      _errors.emit(toFailure(e).getMessage());
    }
  }

  Future<void> _run(Future<ProductPrice> Function() action) async {
    if (_state.value.loading) return;
    _state.value = _state.value.copyWith(loading: true);
    try {
      _completed.emit(await action());
    } on Exception catch (e) {
      _errors.emit(toFailure(e).getMessage());
    } finally {
      _state.value = _state.value.copyWith(loading: false);
    }
  }

  void dispose() {
    _state.dispose();
    _completed.dispose();
    _errors.dispose();
  }
}
