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

  final _productItems = StreamController<List<Product>>();

  Stream<List<Product>> get productItems => _productItems.stream;

  List<Product> _products = [];

  void prepareData() async {
    getProducts();
  }

  void getProducts() async {
    try {
      _products = await productRepo.getLocalProducts();
      _onSearchProductSuccess(_products);
    } on Exception catch (_) {}
  }

  void searchProduct(String text) {
    if (text.isEmpty) {
      _onSearchProductSuccess(_products);
    } else {
      List<Product> filtered = [];
      for (var item in _products) {
        if (item.name.toLowerCase().contains(text.toLowerCase()) || item.serialNumber.contains(text)) {
          filtered.add(item);
        }
      }
      _onSearchProductSuccess(filtered);
    }
  }

  void getProductBySerialNumber(String serialNumber) async {
    try {
      final result = await productRepo.getProductBySerialNumber(serialNumber);
    } on Exception catch (e) {}
  }

  void _onSearchProductSuccess(List<Product> result) {
    if (!_productItems.isClosed) {
      _productItems.sink.add(result);
    }
  }

  dispose() {
    _productItems.close();
  }
}
