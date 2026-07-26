// Flutter imports:
import 'package:flutter/foundation.dart';

import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';
import 'package:pos/presentation/home/main/product_search_state.dart';

class ProductSearchViewModel {
  final GetLocalProductsUseCase getLocalProductsUseCase;

  ProductSearchViewModel({
    required this.getLocalProductsUseCase,
  });

  final _state = ValueNotifier<ProductSearchState>(const ProductSearchState());

  ValueListenable<ProductSearchState> get state => _state;

  final List<ProductUnitItem> _products = [];

  Future<void> prepareData() async {
    await getProducts();
  }

  Future<void> getProducts() async {
    _state.value = _state.value.copyWith(loading: true, clearError: true);
    try {
      _products.clear();
      final products = await getLocalProductsUseCase();
      for (var item in products) {
        if (item.status == productStatusActive) {
          _products.addAll(item.toProductItems());
        }
      }
      _state.value = _state.value.copyWith(
        loading: false,
        items: List<ProductUnitItem>.of(_products),
      );
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(
        loading: false,
        error: toFailure(e).getMessage(),
      );
    }
  }

  void searchProduct(String text) {
    if (text.isEmpty) {
      _state.value =
          _state.value.copyWith(items: List<ProductUnitItem>.of(_products));
    } else {
      final lower = text.toLowerCase();
      _state.value = _state.value.copyWith(
          items: _products
              .where((item) =>
                  item.name.toLowerCase().contains(lower) ||
                  item.unit.barcode.contains(text))
              .toList());
    }
  }

  void dispose() {
    _state.dispose();
  }
}
