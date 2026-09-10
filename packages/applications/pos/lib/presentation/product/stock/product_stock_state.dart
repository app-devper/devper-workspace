// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class ProductStockTask {
  const ProductStockTask._();
  const factory ProductStockTask() = ProductStockIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductStockRunning;
  String? get error => switch (this) {
        ProductStockFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  ProductStock? get completed => switch (this) {
        ProductStockCompleted(:final result) => result,
        _ => null,
      };
}

final class ProductStockIdle extends ProductStockTask {
  const ProductStockIdle() : super._();
}

final class ProductStockRunning extends ProductStockTask {
  const ProductStockRunning() : super._();
}

final class ProductStockCompleted extends ProductStockTask {
  final ProductStock result;
  const ProductStockCompleted(this.result) : super._();
}

final class ProductStockFailed extends ProductStockTask {
  final Failure failure;
  const ProductStockFailed(this.failure) : super._();
}

@immutable
class ProductStockState {
  final ProductStockTask task;

  final List<ProductStock> items;

  const ProductStockState({
    this.task = const ProductStockIdle(),
    this.items = const [],
  });

  bool get loading => task.running;

  String? get error => task.error;

  ProductStock? get completed => task.completed;

  ProductStockState copyWith({
    ProductStockTask? task,
    List<ProductStock>? items,
  }) {
    return ProductStockState(
      task: task ?? this.task,
      items: items ?? this.items,
    );
  }
}
