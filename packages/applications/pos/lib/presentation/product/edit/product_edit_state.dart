// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

/// Everything this screen can be doing to the product: fetching it, saving it,
/// deleting it, or asking the server for a serial number.
///
/// One command runs at a time and produces one result, so they share a slot
/// rather than four nullable fields that nothing kept from all being set.
sealed class ProductEditTask {
  const ProductEditTask._();
  const factory ProductEditTask() = ProductEditIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductEditRunning;
  String? get error => switch (this) {
        ProductEditFailed(:final failure) => failure.getMessage(),
        ProductMissing() => 'Product not found',
        _ => null,
      };
  Product? get loaded => switch (this) {
        ProductLoaded(:final product) => product,
        _ => null,
      };
  Product? get updated => switch (this) {
        ProductUpdated(:final product) => product,
        _ => null,
      };
  Product? get removed => switch (this) {
        ProductRemoved(:final product) => product,
        _ => null,
      };
  String? get serialNumber => switch (this) {
        SerialNumberReady(:final value) => value,
        _ => null,
      };
}

final class ProductEditIdle extends ProductEditTask {
  const ProductEditIdle() : super._();
}

final class ProductEditRunning extends ProductEditTask {
  const ProductEditRunning() : super._();
}

final class ProductLoaded extends ProductEditTask {
  final Product product;
  const ProductLoaded(this.product) : super._();
}

final class ProductUpdated extends ProductEditTask {
  final Product product;
  const ProductUpdated(this.product) : super._();
}

final class ProductRemoved extends ProductEditTask {
  final Product product;
  const ProductRemoved(this.product) : super._();
}

final class SerialNumberReady extends ProductEditTask {
  final String value;
  const SerialNumberReady(this.value) : super._();
}

/// The lookup succeeded but the product is gone. Distinct from a request that
/// failed, which is why it carries no Failure and keeps its own message.
final class ProductMissing extends ProductEditTask {
  const ProductMissing() : super._();
}

final class ProductEditFailed extends ProductEditTask {
  final Failure failure;
  const ProductEditFailed(this.failure) : super._();
}

@immutable
class ProductEditState {
  final ProductEditTask task;

  /// The picker's options. Screen data, not a flag.
  final List<Category> categories;

  const ProductEditState({
    this.task = const ProductEditIdle(),
    this.categories = const [],
  });

  bool get loading => task.running;

  String? get error => task.error;

  Product? get loaded => task.loaded;

  Product? get updated => task.updated;

  Product? get removed => task.removed;

  String? get serialNumber => task.serialNumber;

  ProductEditState copyWith({
    ProductEditTask? task,
    List<Category>? categories,
  }) {
    return ProductEditState(
      task: task ?? this.task,
      categories: categories ?? this.categories,
    );
  }
}
