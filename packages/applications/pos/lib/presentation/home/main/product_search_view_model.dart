// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/usecase/product/get_local_products_use_case.dart';

class ProductSearchViewModel {
  final GetLocalProductsUseCase getLocalProductsUseCase;

  ProductSearchViewModel({
    required this.getLocalProductsUseCase,
  });

  final _items = ValueNotifier<List<ProductUnitItem>?>(null);

  ValueListenable<List<ProductUnitItem>?> get items => _items;

  /// Non-null when the inventory could not be loaded. The grid renders this
  /// instead of spinning forever, and the message says the shop is offline
  /// rather than leaving the till to conclude it stocks nothing.
  final _error = ValueNotifier<String?>(null);

  ValueListenable<String?> get error => _error;

  final List<ProductUnitItem> _products = [];

  Future<void> prepareData() async {
    await getProducts();
  }

  Future<void> getProducts() async {
    _error.value = null;
    _items.value = null;
    try {
      _products.clear();
      final products = await getLocalProductsUseCase();
      for (var item in products) {
        if (item.status == productStatusActive) {
          _products.addAll(item.toProductItems());
        }
      }
      _items.value = List<ProductUnitItem>.of(_products);
    } on Exception catch (e) {
      _error.value = toFailure(e).getMessage();
    }
  }

  void searchProduct(String text) {
    if (text.isEmpty) {
      _items.value = List<ProductUnitItem>.of(_products);
    } else {
      final lower = text.toLowerCase();
      _items.value = _products
          .where((item) =>
              item.name.toLowerCase().contains(lower) ||
              item.unit.barcode.contains(text))
          .toList();
    }
  }

  void dispose() {
    _items.dispose();
    _error.dispose();
  }
}
