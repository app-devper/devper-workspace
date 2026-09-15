// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:pos/domain/model/stock_count/param.dart';
import 'package:pos/domain/model/stock_count/stock_count.dart';

/// What this screen renders: the document being counted, the lines on it, and
/// whether a command is in flight.
///
/// The outcome and the validation messages used to sit here behind a sealed
/// task the view cleared. Neither is drawn — one closes the screen, the other
/// flashes — so both go out on the view model's event channel.
@immutable
class StockCountManageState {
  final bool loading;
  final StockCount? stockCount;
  final List<StockCountItemParam> items;

  const StockCountManageState({
    this.loading = false,
    this.stockCount,
    this.items = const [],
  });

  StockCountManageState copyWith({
    bool? loading,
    StockCount? stockCount,
    List<StockCountItemParam>? items,
  }) {
    return StockCountManageState(
      loading: loading ?? this.loading,
      stockCount: stockCount ?? this.stockCount,
      items: items ?? this.items,
    );
  }
}
