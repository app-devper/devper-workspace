import 'package:common/core/error/failure.dart';
import 'package:pos/domain/model/stock_adjustment/stock_adjustment.dart';

/// The mutually exclusive states of this screen's submit flow.
sealed class StockAdjustmentState {
  const StockAdjustmentState._();
  const factory StockAdjustmentState() = StockAdjustmentIdle;

  // Derived UI projections; no independently writable boolean flags.
  bool get loading => this is StockAdjustmentSubmitting;
  String? get error => switch (this) {
        StockAdjustmentFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  StockAdjustment? get created => switch (this) {
        StockAdjustmentSucceeded(:final result) => result,
        _ => null,
      };
}

final class StockAdjustmentIdle extends StockAdjustmentState {
  const StockAdjustmentIdle() : super._();
}

final class StockAdjustmentSubmitting extends StockAdjustmentState {
  const StockAdjustmentSubmitting() : super._();
}

final class StockAdjustmentSucceeded extends StockAdjustmentState {
  final StockAdjustment result;
  const StockAdjustmentSucceeded(this.result) : super._();
}

final class StockAdjustmentFailed extends StockAdjustmentState {
  final Failure failure;
  const StockAdjustmentFailed(this.failure) : super._();
}
