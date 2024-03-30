// Dart imports:
import 'dart:async';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductsViewModel {
  final ProductRepository productRepo;

  ProductsViewModel({
    required this.productRepo,
  });

  final _products = StreamController<List<Product>>();

  Stream<List<Product>> get products => _products.stream;

  void searchProduct(String text, bool sortBalance) async {
    try {
      final result = await productRepo.getLocalProducts();
      _onListProducts(text, result, sortBalance);
    } on Exception catch (e) {
      _onError(toFailure(e));
    }
  }

  _onListProducts(String text, List<Product> data, bool sortBalance) {
    if (!_products.isClosed) {
      List<Product> items = [];
      items.addAll(data);
      final result = _searchProduct(text, items);
      if (sortBalance) {
        result.sort((a, b) => a.getQuantity().compareTo(b.getQuantity()));
      }
      _products.sink.add(result);
    }
  }

  _onError(Failure failure) {
    if (!_products.isClosed) {
      _products.sink.addError(failure.getMessage());
    }
  }

  dispose() {
    _products.close();
  }

  List<Product> _searchProduct(String param, List<Product> data) {
    if (param.isEmpty) {
      return data;
    } else {
      List<Product> filtered = [];
      for (var item in data) {
        if (item.name.toLowerCase().contains(param.toLowerCase()) || item.units.any((element) => element.barcode.contains(param))) {
          filtered.add(item);
        }
      }
      return filtered;
    }
  }
}
