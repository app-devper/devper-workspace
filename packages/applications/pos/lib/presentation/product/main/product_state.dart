// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product.dart';
import 'package:pos/domain/model/product/product_history.dart';

/// What this screen can be doing: fetching one product, clearing its
/// sold-first flag, exporting the catalogue or importing a CSV.
///
/// One at a time, one result each, so they share a slot instead of separate
/// nullable payloads that could all be set at once.
sealed class ProductTask {
  const ProductTask._();
  const factory ProductTask() = ProductTaskIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductTaskRunning;
  String? get error => switch (this) {
        ProductTaskFailed(:final failure) => failure.getMessage(),
        ProductNotFound() => 'Product not found',
        _ => null,
      };
  Product? get loaded => switch (this) {
        ProductFound(:final product) => product,
        _ => null,
      };
  CSVImportResult? get importResult => switch (this) {
        ImportFinished(:final result) => result,
        _ => null,
      };
}

final class ProductTaskIdle extends ProductTask {
  const ProductTaskIdle() : super._();
}

final class ProductTaskRunning extends ProductTask {
  const ProductTaskRunning() : super._();
}

final class ProductFound extends ProductTask {
  final Product product;
  const ProductFound(this.product) : super._();
}

final class ImportFinished extends ProductTask {
  final CSVImportResult result;
  const ImportFinished(this.result) : super._();
}

/// The cache answered, and it has no such product. Not a failed request.
final class ProductNotFound extends ProductTask {
  const ProductNotFound() : super._();
}

final class ProductTaskFailed extends ProductTask {
  final Failure failure;
  const ProductTaskFailed(this.failure) : super._();
}

@immutable
class ProductState {
  final ProductTask task;

  const ProductState({this.task = const ProductTaskIdle()});

  bool get loading => task.running;

  String? get error => task.error;

  Product? get loaded => task.loaded;

  CSVImportResult? get importResult => task.importResult;

  ProductState copyWith({ProductTask? task}) {
    return ProductState(task: task ?? this.task);
  }
}
