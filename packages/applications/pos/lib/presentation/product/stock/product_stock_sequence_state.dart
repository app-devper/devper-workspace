// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class ProductStockSequenceTask {
  const ProductStockSequenceTask._();
  const factory ProductStockSequenceTask() = ProductStockSequenceIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductStockSequenceRunning;
  String? get error => switch (this) {
        ProductStockSequenceFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  List<ProductStock>? get updated => switch (this) {
        ProductStockSequenceUpdated(:final result) => result,
        _ => null,
      };
}

final class ProductStockSequenceIdle extends ProductStockSequenceTask {
  const ProductStockSequenceIdle() : super._();
}

final class ProductStockSequenceRunning extends ProductStockSequenceTask {
  const ProductStockSequenceRunning() : super._();
}

final class ProductStockSequenceUpdated extends ProductStockSequenceTask {
  final List<ProductStock> result;
  const ProductStockSequenceUpdated(this.result) : super._();
}

final class ProductStockSequenceFailed extends ProductStockSequenceTask {
  final Failure failure;
  const ProductStockSequenceFailed(this.failure) : super._();
}

@immutable
class ProductStockSequenceState {
  final ProductStockSequenceTask task;

  const ProductStockSequenceState({
    this.task = const ProductStockSequenceIdle(),
  });

  bool get loading => task.running;

  String? get error => task.error;

  List<ProductStock>? get updated => task.updated;

  ProductStockSequenceState copyWith({
    ProductStockSequenceTask? task,
  }) {
    return ProductStockSequenceState(
      task: task ?? this.task,
    );
  }
}
