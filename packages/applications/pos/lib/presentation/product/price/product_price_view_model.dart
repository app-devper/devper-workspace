// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';
import 'package:common/core/state/one_shot.dart';

// Project imports:
import 'package:pos/domain/model/product/param.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/product/price/product_price_state.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductPriceViewModel {
  final ProductRepository productRepo;

  ProductPriceViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductPriceState>(const ProductPriceState());

  /// Delivered once and gone: the sheet closes on it, nothing draws it.
  final _completed = OneShot<ProductPrice>();
  final _errors = OneShot<String>();

  ValueListenable<ProductPriceState> get state => _state;

  Stream<ProductPrice> get completed => _completed.stream;

  Stream<String> get errors => _errors.stream;

  Future<void> addProductPrice(ProductPriceParam param) async {
    await _run(() => productRepo.addProductPrice(param));
  }

  Future<void> updateProductPriceById(
      String id, ProductPriceParam param) async {
    await _run(() => productRepo.updateProductPriceById(id, param));
  }

  Future<void> removeProductPriceById(String id) async {
    await _run(() => productRepo.removeProductPriceById(id));
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
