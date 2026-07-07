// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product_lot.dart';
import 'package:pos/presentation/product/expired/products_expire_ui_model.dart';

@immutable
class ProductsExpiredState {
  final List<ProductLot> items;
  final double totalCost;
  final List<ListItem> ranges;
  final bool loading;
  final String? error;

  const ProductsExpiredState({
    this.items = const [],
    this.totalCost = 0,
    this.ranges = const [],
    this.loading = false,
    this.error,
  });

  ProductsExpiredState copyWith({
    List<ProductLot>? items,
    double? totalCost,
    List<ListItem>? ranges,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return ProductsExpiredState(
      items: items ?? this.items,
      totalCost: totalCost ?? this.totalCost,
      ranges: ranges ?? this.ranges,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
