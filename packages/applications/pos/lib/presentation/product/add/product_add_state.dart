// Flutter imports:
import 'package:flutter/foundation.dart' hide Category;

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/category/category.dart';
import 'package:pos/domain/model/product/product.dart';

/// Saving the new product, and asking the server for a serial number.
/// Two commands, two results, one at a time.
sealed class ProductAddTask {
  const ProductAddTask._();
  const factory ProductAddTask() = ProductAddIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductAddSaving;
  String? get error => switch (this) {
        ProductAddFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  Product? get created => switch (this) {
        ProductCreated(:final product) => product,
        _ => null,
      };
  String? get serialNumber => switch (this) {
        ProductAddSerialNumber(:final value) => value,
        _ => null,
      };
}

final class ProductAddIdle extends ProductAddTask {
  const ProductAddIdle() : super._();
}

final class ProductAddSaving extends ProductAddTask {
  const ProductAddSaving() : super._();
}

final class ProductCreated extends ProductAddTask {
  final Product product;
  const ProductCreated(this.product) : super._();
}

final class ProductAddSerialNumber extends ProductAddTask {
  final String value;
  const ProductAddSerialNumber(this.value) : super._();
}

final class ProductAddFailed extends ProductAddTask {
  final Failure failure;
  const ProductAddFailed(this.failure) : super._();
}

@immutable
class ProductAddState {
  final ProductAddTask task;

  /// The picker's options. Screen data, not a flag.
  final List<Category> categories;

  const ProductAddState({
    this.task = const ProductAddIdle(),
    this.categories = const [],
  });

  bool get saving => task.running;

  String? get error => task.error;

  Product? get created => task.created;

  String? get serialNumber => task.serialNumber;

  ProductAddState copyWith({
    ProductAddTask? task,
    List<Category>? categories,
  }) {
    return ProductAddState(
      task: task ?? this.task,
      categories: categories ?? this.categories,
    );
  }
}
