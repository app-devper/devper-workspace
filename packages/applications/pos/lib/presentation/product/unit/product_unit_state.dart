// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class ProductUnitTask {
  const ProductUnitTask._();
  const factory ProductUnitTask() = ProductUnitIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductUnitRunning;
  String? get error => switch (this) {
        ProductUnitFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  ProductUnit? get completed => switch (this) {
        ProductUnitCompleted(:final result) => result,
        _ => null,
      };
}

final class ProductUnitIdle extends ProductUnitTask {
  const ProductUnitIdle() : super._();
}

final class ProductUnitRunning extends ProductUnitTask {
  const ProductUnitRunning() : super._();
}

final class ProductUnitCompleted extends ProductUnitTask {
  final ProductUnit result;
  const ProductUnitCompleted(this.result) : super._();
}

final class ProductUnitFailed extends ProductUnitTask {
  final Failure failure;
  const ProductUnitFailed(this.failure) : super._();
}

@immutable
class ProductUnitState {
  final ProductUnitTask task;

  final List<ProductUnit> items;

  const ProductUnitState({
    this.task = const ProductUnitIdle(),
    this.items = const [],
  });

  bool get loading => task.running;

  String? get error => task.error;

  ProductUnit? get completed => task.completed;

  ProductUnitState copyWith({
    ProductUnitTask? task,
    List<ProductUnit>? items,
  }) {
    return ProductUnitState(
      task: task ?? this.task,
      items: items ?? this.items,
    );
  }
}
