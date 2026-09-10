// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class ProductStockQuantityTask {
  const ProductStockQuantityTask._();
  const factory ProductStockQuantityTask() = ProductStockQuantityIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductStockQuantityRunning;
  String? get error => switch (this) {
        ProductStockQuantityFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  ProductStock? get updated => switch (this) {
        ProductStockQuantityUpdated(:final result) => result,
        _ => null,
      };
}

final class ProductStockQuantityIdle extends ProductStockQuantityTask {
  const ProductStockQuantityIdle() : super._();
}

final class ProductStockQuantityRunning extends ProductStockQuantityTask {
  const ProductStockQuantityRunning() : super._();
}

final class ProductStockQuantityUpdated extends ProductStockQuantityTask {
  final ProductStock result;
  const ProductStockQuantityUpdated(this.result) : super._();
}

final class ProductStockQuantityFailed extends ProductStockQuantityTask {
  final Failure failure;
  const ProductStockQuantityFailed(this.failure) : super._();
}

@immutable
class ProductStockQuantityState {
  final ProductStockQuantityTask task;

  const ProductStockQuantityState({
    this.task = const ProductStockQuantityIdle(),
  });

  bool get loading => task.running;

  String? get error => task.error;

  ProductStock? get updated => task.updated;

  ProductStockQuantityState copyWith({
    ProductStockQuantityTask? task,
  }) {
    return ProductStockQuantityState(
      task: task ?? this.task,
    );
  }
}
