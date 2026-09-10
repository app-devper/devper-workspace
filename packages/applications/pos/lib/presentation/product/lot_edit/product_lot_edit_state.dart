// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:common/core/error/failure.dart';

// Project imports:
import 'package:pos/domain/model/product/product_lot.dart';

/// Handing the lot to the form, and saving it back. Two outcomes, never both.
sealed class ProductLotEditTask {
  const ProductLotEditTask._();
  const factory ProductLotEditTask() = ProductLotEditIdle;

  // Derived UI projections; no independently writable flags.
  bool get running => this is ProductLotEditRunning;
  String? get error => switch (this) {
        ProductLotEditFailed(:final failure) => failure.getMessage(),
        _ => null,
      };
  ProductLot? get loaded => switch (this) {
        ProductLotLoaded(:final lot) => lot,
        _ => null,
      };
  ProductLot? get updated => switch (this) {
        ProductLotUpdated(:final lot) => lot,
        _ => null,
      };
}

final class ProductLotEditIdle extends ProductLotEditTask {
  const ProductLotEditIdle() : super._();
}

final class ProductLotEditRunning extends ProductLotEditTask {
  const ProductLotEditRunning() : super._();
}

final class ProductLotLoaded extends ProductLotEditTask {
  final ProductLot lot;
  const ProductLotLoaded(this.lot) : super._();
}

final class ProductLotUpdated extends ProductLotEditTask {
  final ProductLot lot;
  const ProductLotUpdated(this.lot) : super._();
}

final class ProductLotEditFailed extends ProductLotEditTask {
  final Failure failure;
  const ProductLotEditFailed(this.failure) : super._();
}

@immutable
class ProductLotEditState {
  final ProductLotEditTask task;

  const ProductLotEditState({this.task = const ProductLotEditIdle()});

  bool get loading => task.running;

  String? get error => task.error;

  ProductLot? get loaded => task.loaded;

  ProductLot? get updated => task.updated;

  ProductLotEditState copyWith({ProductLotEditTask? task}) {
    return ProductLotEditState(task: task ?? this.task);
  }
}
