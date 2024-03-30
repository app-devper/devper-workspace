// Dart imports:
import 'dart:async';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductSearchViewModel {
  final ProductRepository productRepo;

  ProductSearchViewModel({
    required this.productRepo,
  });

  final _productItems = StreamController<List<ProductUnitItem>>();

  Stream<List<ProductUnitItem>> get productItems => _productItems.stream;

  final List<ProductUnitItem> _products = [];

  void prepareData() async {
    getProducts();
  }

  void getProducts() async {
    try {
      _products.clear();
      final products = await productRepo.getLocalProducts();
      for (var item in products) {
        _products.addAll(item.toProductItems());
      }
      _onSearchProductSuccess(_products);
    } on Exception catch (_) {}
  }

  void searchProduct(String text) {
    if (text.isEmpty) {
      _onSearchProductSuccess(_products);
    } else {
      List<ProductUnitItem> filtered = [];
      for (var item in _products) {
        if (item.name.toLowerCase().contains(text.toLowerCase()) || item.unit.barcode.contains(text)) {
          filtered.add(item);
        }
      }
      _onSearchProductSuccess(filtered);
    }
  }

  void getProductBySerialNumber(String serialNumber) async {
    try {
      final result = await productRepo.getProductBySerialNumber(serialNumber);
    } on Exception {}
  }

  void _onSearchProductSuccess(List<ProductUnitItem> result) {
    if (!_productItems.isClosed) {
      _productItems.sink.add(result);
    }
  }

  dispose() {
    _productItems.close();
  }
}
