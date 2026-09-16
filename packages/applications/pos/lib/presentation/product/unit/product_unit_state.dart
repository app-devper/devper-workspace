// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// What this screen renders: the rows, and whether a command is in flight.
///
/// The outcome used to live here too, in a sealed task the view cleared once it
/// had acted on it. It is not drawn — it closes the sheet and hands the result
/// back — so it goes out on the view model's event channel instead.
@immutable
class ProductUnitState {
  final bool loading;
  final List<ProductUnit> items;

  const ProductUnitState({
    this.loading = false,
    this.items = const [],
  });

  ProductUnitState copyWith({
    bool? loading,
    List<ProductUnit>? items,
  }) {
    return ProductUnitState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
    );
  }
}
