// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/presentation/product/main/products_state.dart';
import 'package:pos/domain/repositories/product_repository.dart';

class ProductsViewModel {
  final ProductRepository productRepo;

  ProductsViewModel({
    required this.productRepo,
  });

  final _state = ValueNotifier<ProductsState>(const ProductsState());
  StreamSubscription<void>? _changes;
  String _query = '';
  bool _sortBalance = false;

  ValueListenable<ProductsState> get state => _state;

  /// Lists the catalogue matching [text], and keeps the list current: a
  /// change anywhere in the catalogue runs the same search again.
  Future<void> searchProduct(String text, bool sortBalance) async {
    _query = text;
    _sortBalance = sortBalance;
    _changes ??= productRepo.catalogueChanges
        .listen((_) => searchProduct(_query, _sortBalance));
    try {
      final data = await productRepo.getLocalProducts();
      final result = _searchProduct(text, List<Product>.of(data));
      if (sortBalance) {
        result.sort((a, b) => a.getQuantity().compareTo(b.getQuantity()));
      }
      _state.value = _state.value
          .copyWith(loading: false, items: result, clearError: true);
    } on Exception catch (e) {
      _state.value = _state.value
          .copyWith(loading: false, error: toFailure(e).getMessage());
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

  void dispose() {
    _changes?.cancel();
    _state.dispose();
  }
}
