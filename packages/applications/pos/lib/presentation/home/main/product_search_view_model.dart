// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/core/core.dart';
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductSearchViewModel {
  final ProductRepository productRepo;

  ProductSearchViewModel({
    required this.productRepo,
  });

  final _items = ValueNotifier<List<ProductUnitItem>?>(null);

  ValueListenable<List<ProductUnitItem>?> get items => _items;

  final List<ProductUnitItem> _products = [];

  Future<void> prepareData() async {
    await getProducts();
  }

  Future<void> getProducts() async {
    try {
      _products.clear();
      final products = await productRepo.getLocalProducts();
      for (var item in products) {
        if (item.status == productStatusActive) {
          _products.addAll(item.toProductItems());
        }
      }
      _items.value = List<ProductUnitItem>.of(_products);
    } on Exception catch (_) {}
  }

  void searchProduct(String text) {
    if (text.isEmpty) {
      _items.value = List<ProductUnitItem>.of(_products);
    } else {
      final lower = text.toLowerCase();
      _items.value = _products
          .where((item) => item.name.toLowerCase().contains(lower) || item.unit.barcode.contains(text))
          .toList();
    }
  }

  void dispose() {
    _items.dispose();
  }
}
