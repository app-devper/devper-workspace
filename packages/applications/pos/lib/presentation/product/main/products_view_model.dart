// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/repositories/product_repository.dart';
import 'package:pos/presentation/product/main/products_state.dart';

class ProductsViewModel {
  final ProductRepository productRepo;

  ProductsViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductsState>(const ProductsState());

  ValueListenable<ProductsState> get state => _state;

  Future<void> searchProduct(String text, bool sortBalance) async {
    try {
      final data = await productRepo.getLocalProducts();
      final result = _searchProduct(text, List<Product>.of(data));
      if (sortBalance) {
        result.sort((a, b) => a.getQuantity().compareTo(b.getQuantity()));
      }
      _state.value = _state.value.copyWith(loading: false, items: result, clearError: true);
    } on Exception catch (e) {
      _state.value = _state.value.copyWith(loading: false, error: toFailure(e).getMessage());
    }
  }

  List<Product> _searchProduct(String param, List<Product> data) {
    if (param.isEmpty) {
      return data;
    }
    final lower = param.toLowerCase();
    return data
        .where((item) =>
            item.name.toLowerCase().contains(lower) ||
            item.units.any((element) => element.barcode.contains(param)))
        .toList();
  }

  void consumeError() {
    if (_state.value.error != null) {
      _state.value = _state.value.copyWith(clearError: true);
    }
  }

  void dispose() {
    _state.dispose();
  }
}
