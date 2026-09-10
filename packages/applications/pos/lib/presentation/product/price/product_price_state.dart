// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';

/// The one thing this screen does, as a flow rather than a bag of flags:
/// it is idle, running, finished with a result, or failed. Never two at once.
sealed class ProductPriceTask {
  const ProductPriceTask._();
  const factory ProductPriceTask() = ProductPriceIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductPriceRunning;
  String? get error => switch (this) {
        ProductPriceFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  ProductPrice? get completed => switch (this) {
        ProductPriceCompleted(:final result) => result,
        _ => null,
      };
}

final class ProductPriceIdle extends ProductPriceTask {
  const ProductPriceIdle() : super._();
}

final class ProductPriceRunning extends ProductPriceTask {
  const ProductPriceRunning() : super._();
}

final class ProductPriceCompleted extends ProductPriceTask {
  final ProductPrice result;
  const ProductPriceCompleted(this.result) : super._();
}

final class ProductPriceFailed extends ProductPriceTask {
  final Failure failure;
  const ProductPriceFailed(this.failure) : super._();
}

@immutable
class ProductPriceState {
  final ProductPriceTask task;

  final List<ProductPrice> items;

  const ProductPriceState({
    this.task = const ProductPriceIdle(),
    this.items = const [],
  });

  bool get loading => task.running;

  String? get error => task.error;

  ProductPrice? get completed => task.completed;

  ProductPriceState copyWith({
    ProductPriceTask? task,
    List<ProductPrice>? items,
  }) {
    return ProductPriceState(
      task: task ?? this.task,
      items: items ?? this.items,
    );
  }
}
